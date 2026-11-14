// fa::hooks on macOS: inline hooks (mac/inline_hook.cpp) on the same game functions the Windows layer detours.
#include "hooks.h"
#include <pthread.h>
#include <atomic>
#include <chrono>
#include <condition_variable>
#include <deque>
#include <memory>
#include <mutex>
#include <string>
#include <vector>
#include <filesystem>
#include "assets.h"
#include "log.h"
#include "input.h"
#include "lua_native.h"
#include "mac/abi.h"
#include "mac/inline_hook.h"
#include "mac/speech_mac.h"
#include "sym.h"

namespace fa::hooks {
namespace {
struct Hook {
  void* target;
  void* detour;
  void** orig;
  const char* label;
  bool ok;
};
std::vector<Hook> g_hooks;

std::mutex g_jobs_mu;
std::deque<std::function<void()>> g_jobs;
std::atomic<uint64_t> g_frame;
std::atomic<unsigned long> g_main_tid;
std::function<void()> g_on_frame;

unsigned long tid() {
  uint64_t t = 0;
  pthread_threadid_np(nullptr, &t);
  return (unsigned long)t;
}

void drain_jobs() {
  for (;;) {
    std::function<void()> j;
    {
      std::lock_guard lk(g_jobs_mu);
      if (g_jobs.empty()) return;
      j = std::move(g_jobs.front());
      g_jobs.pop_front();
    }
    j();
  }
}

// MainLoop::mainLoopStep(WorkerThread&, MainLoop::HeavyMode): one iteration of the main thread's loop.
using MainLoopStep_t = int (*)(void*, int);
MainLoopStep_t MainLoopStep_orig;
void install_table_hooks();

// On the Mac, MainLoop::run calls mainLoopStep back to back, about 1500 times a second, and the step itself decides
// whether to draw; on Windows it blocks on presenting a frame. The native UI's frame (input, screens, jobs) runs at
// most this often: four times the game's 60, at a sixth of the cost of running on every step. Keys wait in
// fa::input until the next frame.
constexpr auto kMinFrame = std::chrono::microseconds(1'000'000 / 240);
std::chrono::steady_clock::time_point g_last_frame;

int MainLoopStep_hook(void* worker, int heavy) {
  if (!g_main_tid) {
    g_main_tid = tid();
    log::writef("hooks: first frame on thread {}", (unsigned long)g_main_tid);
    install_table_hooks();  // SDL has filled its dynapi jump table by now
  }
  auto now = std::chrono::steady_clock::now();
  if (now - g_last_frame < kMinFrame) return MainLoopStep_orig(worker, heavy);
  g_last_frame = now;
  ++g_frame;
  input::begin_frame();
  drain_jobs();
  if (g_on_frame) g_on_frame();
  input::end_frame();
  return MainLoopStep_orig(worker, heavy);
}

// ======================= input: SDLWindow::pollEvent =======================
// The game drains SDL through SDLWindow::pollEvent(Event&), which hands out its own converted Event. While the
// native UI owns the keyboard, key events stop here: recorded for the UI, never returned to the game.
struct EventLayout {
  size_t type, kb_scancode, kb_mod, kb_unichar, kb_repeat;  // Event::type, Event::keyboard.<field>
  size_t window_sdl;                                        // SDLWindow::window
} E;
// Event::Type values (the same as on Windows; read off Event::convertSDLEvent's jump table).
constexpr int kKeyDown = 0, kKeyChar = 1, kKeyUp = 2, kKeyComposition = 3;
// SDL3's public event layout (SDL_events.h): SDL_KeyboardEvent, SDL_TextInputEvent, SDL_MouseMotionEvent.
constexpr size_t kSdlType = 0, kSdlWindow = 16, kSdlScancode = 24, kSdlKey = 28, kSdlMod = 32, kSdlDown = 36;
constexpr size_t kSdlText = 24, kSdlMotionX = 28, kSdlMotionY = 32;
constexpr uint32_t kSdlKeyDown = 0x300, kSdlKeyUp = 0x301, kSdlTextInput = 0x303, kSdlMouseMotion = 0x400;
constexpr uint16_t kModShift = 0x0003, kModCtrl = 0x00c0, kModAlt = 0x0300;

bool resolve_events() {
  bool ok = true;
  auto off = [&](const char* t, const char* m) {
    auto r = sym::offset(t, m);
    ok &= r.has_value();
    return r.value_or(0);
  };
  size_t kb = off("Event", "keyboard");
  E.type = off("Event", "type");
  E.kb_scancode = kb + off("KeyboardEvent", "scancode");
  E.kb_mod = kb + off("KeyboardEvent", "mod");
  E.kb_unichar = kb + off("KeyboardEvent", "unichar");
  E.kb_repeat = kb + off("KeyboardEvent", "repeat");
  E.window_sdl = off("SDLWindow", "window");
  return ok;
}

template <typename T>
T& field(void* base, size_t off) {
  return *reinterpret_cast<T*>(reinterpret_cast<char*>(base) + off);
}

std::atomic<void*> g_sdl_window;  // SDL_Window*, captured from the first pollEvent
using PollEvent_t = bool (*)(void*, void*);
PollEvent_t PollEvent_orig;
bool PollEvent_hook(void* self, void* ev) {
  if (!g_sdl_window) g_sdl_window = field<void*>(self, E.window_sdl);
  for (;;) {
    if (!PollEvent_orig(self, ev)) return false;
    int type = field<int>(ev, E.type);
    if (type < kKeyDown || type > kKeyComposition) return true;
    // Every key is recorded (a screen that lent the keyboard to the game still watches for the keys that end
    // the loan); it is only swallowed while the native UI owns the keyboard.
    bool swallow = input::owned() || (type != kKeyChar && type != kKeyComposition && input::reserved(field<int>(ev, E.kb_scancode)));
    if (type == kKeyChar) {
      char32_t c = (char32_t)field<int>(ev, E.kb_unichar);
      input::record_text(std::u32string_view(&c, 1));
    } else if (type != kKeyComposition) {
      if (type == kKeyDown && !field<bool>(ev, E.kb_repeat)) speech::key_pressed();
      uint16_t mod = field<uint16_t>(ev, E.kb_mod);
      input::record_key({field<int>(ev, E.kb_scancode), type == kKeyDown, field<bool>(ev, E.kb_repeat), (mod & kModShift) != 0,
                         (mod & kModCtrl) != 0, (mod & kModAlt) != 0});
    }
    if (!swallow) return true;
  }
}

// ======================= SDL through its dynapi jump table =======================
// The game's SDL3 is static with the dynamic API: SDL_Foo is a three-instruction stub (adrp, ldr, br) through a
// table of pointers to SDL_Foo_REAL. Both are too short to patch, so a hook swaps the table's pointer instead.
void** jump_slot(const char* stub) {
  auto* code = static_cast<const uint32_t*>(sym::addr(stub));
  if (!code || (code[0] & 0x9f000000) != 0x90000000 || (code[1] & 0xffc00000) != 0xf9400000) return nullptr;
  uint64_t pc = reinterpret_cast<uint64_t>(code);
  int64_t immhi = (code[0] >> 5) & 0x7ffff, immlo = (code[0] >> 29) & 3;
  int64_t page_off = ((immhi << 2) | immlo) << 12;
  if (page_off & (int64_t(1) << 32)) page_off -= int64_t(1) << 33;  // sign of the 33-bit page offset
  uint64_t page = (pc & ~0xfffull) + page_off;
  uint64_t slot = page + (((code[1] >> 10) & 0xfff) << 3);
  return reinterpret_cast<void**>(slot);
}

// SDL updates its modifier state only for physical keys, so a pushed Ctrl+A arrives as a bare A to code that asks
// SDL_GetModState. While a synthetic key is held, its modifiers are added to the answer.
std::atomic<uint16_t> g_synthetic_mod;
using GetModState_t = uint16_t (*)();
GetModState_t GetModState_orig;
uint16_t GetModState_hook() { return GetModState_orig() | g_synthetic_mod.load(); }

void install_table_hooks() {
  void** slot = jump_slot("SDL_GetModState");
  if (!slot || !*slot) {
    log::write("hooks: SDL_GetModState's jump table slot not found; synthetic modifiers will not show");
    return;
  }
  GetModState_orig = reinterpret_cast<GetModState_t>(*slot);
  *slot = reinterpret_cast<void*>(&GetModState_hook);
  log::write("hooks: SDL_GetModState hooked through the jump table");
}

using PushEvent_t = bool (*)(void*);
using GetWindowID_t = uint32_t (*)(void*);
using GetKeyFromScancode_t = uint32_t (*)(int, uint16_t, bool);
PushEvent_t g_push_event;
GetWindowID_t g_get_window_id;
GetKeyFromScancode_t g_key_from_scancode;

// The mod whose script state is being built on this thread: LuaGameScript's constructor names it, and
// LuaHelper::initLuaState runs inside it.
thread_local std::string t_creating_mod;

// LuaGameScript::LuaGameScript(std::string const& name, PackagePath const& x4, Mod const*, LuaRemote*, ...): the
// base-object constructor (C2), which the complete-object one tail-calls. Fifteen arguments after `this`.
size_t g_mod_package, g_package_path;  // Mod::package (unique_ptr<Package>), Package::packagePath_ (std::filesystem::path)

// Where FactorioAccess's files are: the engine's own package for the mod (a directory, or the installed zip). On the
// Mac a std::filesystem::path is one UTF-8 std::string.
void note_mod_package(const void* mod) {
  if (!mod) return;
  const void* package = *reinterpret_cast<void* const*>(reinterpret_cast<const char*>(mod) + g_mod_package);
  if (!package) return;
  auto& path = *reinterpret_cast<const mac::abi::String*>(reinterpret_cast<const char*>(package) + g_package_path);
  assets::set_package(std::filesystem::path(path.str()).wstring());
}

using LuaGameScriptCtor_t = void* (*)(void*, const mac::abi::String*, void*, void*, void*, void*, void*, void*, void*, void*, void*,
                                      void*, void*, void*, void*, void*);
LuaGameScriptCtor_t LuaGameScriptCtor_orig;
void* LuaGameScriptCtor_hook(void* self, const mac::abi::String* name, void* a2, void* a3, void* a4, void* a5, void* a6, void* a7, void* a8,
                             void* a9, void* a10, void* a11, void* a12, void* a13, void* a14, void* a15) {
  struct Clear {
    ~Clear() { t_creating_mod.clear(); }  // also when the mod's script fails to load (a C++ exception)
  } clear;
  t_creating_mod = name->str();
  if (t_creating_mod == "mod-FactorioAccess") note_mod_package(a6);  // a6: Mod const*
  return LuaGameScriptCtor_orig(self, name, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15);
}

using InitLuaState_t = void (*)(void*);
InitLuaState_t InitLuaState_orig;
void InitLuaState_hook(void* L) {
  InitLuaState_orig(L);
  // Script names are "mod-<mod name>" for mods and "level" for the scenario's own script.
  std::string_view name = t_creating_mod;
  if (name.starts_with("mod-")) lua::on_state_created(L, name.substr(4));
}
}  // namespace

uint64_t frame() { return g_frame; }
unsigned long main_thread_id() { return g_main_tid; }
unsigned long current_thread_id() { return tid(); }
void set_frame_callback(std::function<void()> fn) { g_on_frame = std::move(fn); }

bool run_on_main_thread(std::function<void()> fn, unsigned timeout_ms) {
  struct State {
    std::mutex m;
    std::condition_variable cv;
    bool done = false;
    std::function<void()> fn;
  };
  auto st = std::make_shared<State>();
  st->fn = std::move(fn);
  {
    std::lock_guard lk(g_jobs_mu);
    g_jobs.push_back([st] {
      st->fn();
      {
        std::lock_guard l2(st->m);
        st->done = true;
      }
      st->cv.notify_all();
    });
  }
  std::unique_lock lk(st->m);
  return st->cv.wait_for(lk, std::chrono::milliseconds(timeout_ms), [&] { return st->done; });
}

bool install() {
  if (!resolve_events()) return false;
  g_push_event = sym::fn<PushEvent_t>("SDL_PushEvent");
  g_get_window_id = sym::fn<GetWindowID_t>("SDL_GetWindowID");
  g_key_from_scancode = sym::fn<GetKeyFromScancode_t>("SDL_GetKeyFromScancode");
  if (!g_push_event || !g_get_window_id || !g_key_from_scancode) return false;
  {
    auto mp = sym::offset("Mod", "package"), pp = sym::offset("Package", "packagePath_");
    if (!mp || !pp) return false;
    g_mod_package = *mp;
    g_package_path = *pp;
  }
  g_hooks = {
      Hook{sym::addr("MainLoop::mainLoopStep"), (void*)&MainLoopStep_hook, (void**)&MainLoopStep_orig, "MainLoop::mainLoopStep", false},
      Hook{sym::addr("SDLWindow::pollEvent"), (void*)&PollEvent_hook, (void**)&PollEvent_orig, "SDLWindow::pollEvent", false},
      Hook{sym::addr("LuaGameScript::LuaGameScript"), (void*)&LuaGameScriptCtor_hook, (void**)&LuaGameScriptCtor_orig,
           "LuaGameScript::LuaGameScript", false},
      Hook{sym::addr("LuaHelper::initLuaState"), (void*)&InitLuaState_hook, (void**)&InitLuaState_orig, "LuaHelper::initLuaState", false},
  };
  int ok = 0;
  for (auto& h : g_hooks) {
    h.ok = mac::inline_hook::attach(h.target, h.detour, h.orig, h.label);
    ok += h.ok;
  }
  log::writef("hooks: {}/{} attached", ok, g_hooks.size());
  return ok == (int)g_hooks.size();
}

void remove() {
  for (auto& h : g_hooks)
    if (h.ok) {
      mac::inline_hook::detach(h.target);
      h.ok = false;
    }
}

bool push_key(int scancode, bool down, bool shift, bool ctrl, bool alt) {
  void* win = g_sdl_window;
  if (!win || !g_push_event) return false;
  alignas(8) unsigned char ev[128] = {};  // sizeof(SDL_Event)
  uint16_t mod = (shift ? 0x0001 : 0) | (ctrl ? 0x0040 : 0) | (alt ? 0x0100 : 0);  // the left-hand modifier bits
  g_synthetic_mod = down ? mod : 0;
  field<uint32_t>(ev, kSdlType) = down ? kSdlKeyDown : kSdlKeyUp;
  field<uint32_t>(ev, kSdlWindow) = g_get_window_id(win);
  field<int>(ev, kSdlScancode) = scancode;
  field<uint32_t>(ev, kSdlKey) = g_key_from_scancode(scancode, mod, false);
  field<uint16_t>(ev, kSdlMod) = mod;
  field<bool>(ev, kSdlDown) = down;
  return g_push_event(ev);
}

bool push_text(std::string_view utf8) {
  void* win = g_sdl_window;
  if (!win || !g_push_event || utf8.empty()) return false;
  // The event carries a pointer: keep every distinct string alive for the life of the process (dev use only).
  static std::mutex mu;
  static std::deque<std::string> kept;
  const char* text;
  {
    std::lock_guard lk(mu);
    kept.emplace_back(utf8);
    text = kept.back().c_str();
  }
  alignas(8) unsigned char ev[128] = {};
  field<uint32_t>(ev, kSdlType) = kSdlTextInput;
  field<uint32_t>(ev, kSdlWindow) = g_get_window_id(win);
  field<const char*>(ev, kSdlText) = text;
  return g_push_event(ev);
}

bool push_mouse_move(float x, float y) {
  void* win = g_sdl_window;
  if (!win || !g_push_event) return false;
  alignas(8) unsigned char ev[128] = {};
  field<uint32_t>(ev, kSdlType) = kSdlMouseMotion;
  field<uint32_t>(ev, kSdlWindow) = g_get_window_id(win);
  field<float>(ev, kSdlMotionX) = x;
  field<float>(ev, kSdlMotionY) = y;
  return g_push_event(ev);
}
}  // namespace fa::hooks
