#include "lua_native.h"
#include <atomic>
#include <cstddef>
#include <string>
#include "audio/audio.h"
#include "hooks.h"
#include "mouse.h"
#include "log.h"
#include "speech.h"
#include "sym.h"
#include "ui/rich_text.h"

namespace fa::lua {
namespace {
using lua_State = void;
using lua_CFunction = int (*)(lua_State*);

// The Lua 5.2 C API as compiled into factorio.exe (as C++: a Lua error is a C++ exception, so every frame
// between here and the Lua call must unwind cleanly -- RAII only, no raw resources held across these calls).
struct Api {
  void (*createtable)(lua_State*, int, int);
  void (*pushcclosure)(lua_State*, lua_CFunction, int);
  void (*pushinteger)(lua_State*, long long);
  void (*setfield)(lua_State*, int, const char*);
  void (*setglobal)(lua_State*, const char*);
  int (*gettop)(lua_State*);
  int (*toboolean)(lua_State*, int);
  const char* (*checklstring)(lua_State*, int, size_t*);
  long long (*checkinteger)(lua_State*, int);
  int (*sethook)(lua_State*, void (*)(lua_State*, void*), int, int);
  void (*traceback)(lua_State*, lua_State*, const char*, int);
  const char* (*tolstring)(lua_State*, int, size_t*);
  void (*settop)(lua_State*, int);
} api;

// MSVC std::string, as returned by reference from the engine.
struct MsvcString {
  union {
    char buf[16];
    const char* ptr;
  };
  size_t size;
  size_t cap;
  std::string str() const { return std::string(cap > 15 ? ptr : buf, size); }
};

// static LocalisedString LuaHelper::parseLocalisedString(lua_State*, int index, bool) -- returned by value
// through a hidden first argument. The bool is what localised_print passes (true).
using Parse_t = void* (*)(void* out, lua_State*, int, bool);
// std::string const& LocalisedString::str(LocaleProvider const*) const
using Str_t = const MsvcString* (*)(const void* self, const void* provider);
using Dtor_t = void (*)(void* self);
// LocaleProvider const* GlobalContext::getActiveLocaleProvider() const
using Provider_t = const void* (*)(const void* global);

Parse_t g_parse;
Str_t g_str;
Dtor_t g_dtor;
Provider_t g_provider;
void* g_global_var;
size_t g_ls_size;
constexpr size_t kLsBuffer = 256;
constexpr long long kApiVersion = 1;

// Keeps the parsed LocalisedString's destructor on every exit path, Lua errors included.
struct ParsedLocalisedString {
  alignas(16) unsigned char storage[kLsBuffer];
  bool constructed = false;
  ~ParsedLocalisedString() {
    if (constructed) g_dtor(storage);
  }
};

// The thread the mod's Lua runs on, noted by each call into the native code, for the watchdog.
std::atomic<unsigned long> g_script_tid;

std::string localise(lua_State* L, int index) {
  ParsedLocalisedString ls;
  g_parse(ls.storage, L, index, true);  // raises a Lua error for a malformed localised string
  ls.constructed = true;
  const void* provider = g_provider(*reinterpret_cast<void**>(g_global_var));
  return g_str(ls.storage, provider)->str();
}

// _fa_native.speak(localised_string [, interrupt])
int lua_speak(lua_State* L) {
  g_script_tid = hooks::current_thread_id();
  bool interrupt = api.gettop(L) < 2 || api.toboolean(L, 2) != 0;
  // Localised control names and item references come back as rich text ([font=...]M[/font]), which the launcher
  // strips too. This also trims the separators that empty parts of a composed message leave at their ends.
  speech::speak(ui::strip_rich_text(localise(L, 1)), interrupt);
  return 0;
}

// _fa_native.audio_cmd(json): one command for the audio engine, in the launcher's JSON format.
std::atomic<uint64_t> g_audio_commands;

int lua_audio_cmd(lua_State* L) {
  g_script_tid = hooks::current_thread_id();
  size_t len = 0;
  const char* json = api.checklstring(L, 1, &len);  // raises a Lua error when not a string
  if (g_audio_commands++ == 0) log::writef("lua: first audio command {}", std::string_view(json, len));
  audio::submit(std::string_view(json, len));
  return 0;
}

// _fa_native.set_cursor(x, y): the mouse pointer to a pixel of the game window, as the launcher's setCursor did.
int lua_set_cursor(lua_State* L) {
  g_script_tid = hooks::current_thread_id();
  long long x = api.checkinteger(L, 1), y = api.checkinteger(L, 2);
  mouse::move_to_client((int)x, (int)y);
  return 0;
}

// The FactorioAccess state, for the watchdog's traceback.
std::atomic<lua_State*> g_mod_state;

void traceback_hook(lua_State* L, void*) {
  api.sethook(L, nullptr, 0, 0);
  api.traceback(L, L, "watchdog: the mod's Lua is running", 0);
  size_t len = 0;
  const char* s = api.tolstring(L, -1, &len);
  log::writef("{}", std::string_view(s ? s : "", s ? len : 0));
  api.settop(L, -2);
}

template <typename T>
bool resolve(T& out, const char* name) {
  out = sym::fn<T>(name);
  return out != nullptr;
}
}  // namespace

bool init() {
  bool ok = true;
  ok &= resolve(api.createtable, "lua_createtable");
  ok &= resolve(api.pushcclosure, "lua_pushcclosure");
  ok &= resolve(api.pushinteger, "lua_pushinteger");
  ok &= resolve(api.setfield, "lua_setfield");
  ok &= resolve(api.setglobal, "lua_setglobal");
  ok &= resolve(api.gettop, "lua_gettop");
  ok &= resolve(api.toboolean, "lua_toboolean");
  ok &= resolve(api.checklstring, "luaL_checklstring");
  ok &= resolve(api.checkinteger, "luaL_checkinteger");
  ok &= resolve(api.sethook, "lua_sethook");
  ok &= resolve(api.traceback, "luaL_traceback");
  ok &= resolve(api.tolstring, "lua_tolstring");
  ok &= resolve(api.settop, "lua_settop");
  ok &= resolve(g_parse, "LuaHelper::parseLocalisedString");
  ok &= resolve(g_str, "LocalisedString::str");
  ok &= resolve(g_dtor, "LocalisedString::~LocalisedString");
  ok &= resolve(g_provider, "GlobalContext::getActiveLocaleProvider");
  g_global_var = sym::addr("global");
  ok &= g_global_var != nullptr;
  auto size = sym::type_size("LocalisedString");
  ok &= size && *size <= kLsBuffer;
  g_ls_size = size.value_or(0);
  log::writef("lua: {} (LocalisedString {} bytes)", ok ? "resolved" : "INCOMPLETE", g_ls_size);
  return ok;
}

uint64_t audio_commands() { return g_audio_commands; }

unsigned long script_thread_id() { return g_script_tid; }

void request_traceback() {
  // LUA_MASKCOUNT (1 << 3): the hook runs after the next 1000 instructions.
  if (lua_State* L = g_mod_state) api.sethook(L, reinterpret_cast<void (*)(lua_State*, void*)>(traceback_hook), 1 << 3, 1000);
}

void on_state_created(void* L, std::string_view mod) {
  if (mod != "FactorioAccess") return;
  g_mod_state = static_cast<lua_State*>(L);
  // Net stack effect zero: the table is consumed by setglobal, each closure by setfield.
  api.createtable(L, 0, 4);
  api.pushinteger(L, kApiVersion);
  api.setfield(L, -2, "api_version");
  api.pushcclosure(L, lua_speak, 0);
  api.setfield(L, -2, "speak");
  api.pushcclosure(L, lua_audio_cmd, 0);
  api.setfield(L, -2, "audio_cmd");
  api.pushcclosure(L, lua_set_cursor, 0);
  api.setfield(L, -2, "set_cursor");
  api.setglobal(L, "_fa_native");
  log::writef("lua: _fa_native installed for {}", mod);
}
}  // namespace fa::lua
