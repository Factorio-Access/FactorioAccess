#include "hooks.h"
#include <windows.h>
#include <detours.h>
#include <intrin.h>
#include <tlhelp32.h>
#include <atomic>
#include <condition_variable>
#include <deque>
#include <memory>
#include <mutex>
#include <string>
#include <string_view>
#include <vector>
#include "input.h"
#include "assets.h"
#include "log.h"
#include "lua_native.h"
#include "sym.h"
#include "win/window.h"

namespace {
// Every Detours transaction must update every thread that may be executing detoured code, not just the
// caller: the main thread runs our hooks every frame, and an unload runs on a remote thread.
struct ThreadUpdater {
  std::vector<HANDLE> handles;
  ThreadUpdater() {
    DetourUpdateThread(GetCurrentThread());
    DWORD pid = GetCurrentProcessId(), me = GetCurrentThreadId();
    HANDLE snap = CreateToolhelp32Snapshot(TH32CS_SNAPTHREAD, 0);
    if (snap == INVALID_HANDLE_VALUE) return;
    THREADENTRY32 te{};
    te.dwSize = sizeof te;
    for (BOOL ok = Thread32First(snap, &te); ok; ok = Thread32Next(snap, &te)) {
      if (te.th32OwnerProcessID != pid || te.th32ThreadID == me) continue;
      HANDLE h = OpenThread(THREAD_SUSPEND_RESUME | THREAD_GET_CONTEXT | THREAD_SET_CONTEXT | THREAD_QUERY_INFORMATION, FALSE, te.th32ThreadID);
      if (!h) continue;
      if (DetourUpdateThread(h) == NO_ERROR) handles.push_back(h);
      else CloseHandle(h);
    }
    CloseHandle(snap);
  }
  ~ThreadUpdater() {
    for (HANDLE h : handles) CloseHandle(h);
  }
};

struct Hook {
  void* target;
  void* detour;
  void** orig;
  const char* label;
  bool ok;
};
}  // namespace

namespace fa::hooks {
static std::vector<Hook> g_hooks;

static void* user32(const char* name) { return (void*)GetProcAddress(GetModuleHandleW(L"user32.dll"), name); }

static void attach_all() {
  DetourTransactionBegin();
  ThreadUpdater threads;
  int ok = 0;
  for (auto& h : g_hooks) {
    if (!h.target) {
      log::writef("hook {}: no target", h.label);
      continue;
    }
    *h.orig = h.target;
    LONG r = DetourAttach(h.orig, h.detour);
    if (r != NO_ERROR) {
      log::writef("hook {}: DetourAttach failed {}", h.label, r);
      *h.orig = nullptr;
      continue;
    }
    h.ok = true;
    ++ok;
  }
  LONG r = DetourTransactionCommit();
  log::writef("hooks: {}/{} attached, commit={}", ok, g_hooks.size(), r);
}

// ======================= main-thread job pump =======================
static std::mutex g_jobs_mu;
static std::deque<std::function<void()>> g_jobs;
static std::atomic<uint64_t> g_frame;
static std::atomic<unsigned long> g_main_tid;
static std::function<void()> g_on_frame;
uint64_t frame() { return g_frame; }
unsigned long main_thread_id() { return g_main_tid; }
unsigned long current_thread_id() { return GetCurrentThreadId(); }
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

static void drain_jobs() {
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

// MainLoop::mainLoopStep(WorkerThread&, HeavyMode) -> ProcessResult: one iteration of the main thread's loop.
using MainLoopStep_t = int (*)(void*, int);
static MainLoopStep_t MainLoopStep_orig;
static int MainLoopStep_hook(void* worker, int heavy) {
  if (!g_main_tid) g_main_tid = GetCurrentThreadId();
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
  size_t sdl_type, sdl_window, sdl_scancode, sdl_key, sdl_mod, sdl_down, sdl_repeat;  // SDL_KeyboardEvent
  size_t sdl_text_window, sdl_text;                                              // SDL_TextInputEvent
  size_t window_sdl;                                                             // SDLWindow::window
} E;
// Event::Type values (enum Event::Type in the PDB).
constexpr int kKeyDown = 0, kKeyChar = 1, kKeyUp = 2, kKeyComposition = 3;
// SDL3: SDL_EVENT_KEY_DOWN / KEY_UP / TEXT_INPUT, and the SDL_Keymod bit groups (SDL_keycode.h).
constexpr uint32_t kSdlKeyDown = 0x300, kSdlKeyUp = 0x301, kSdlTextInput = 0x303;
constexpr uint16_t kModShift = 0x0003, kModCtrl = 0x00c0, kModAlt = 0x0300;

static bool resolve_events() {
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
  E.sdl_type = off("SDL_KeyboardEvent", "type");
  E.sdl_window = off("SDL_KeyboardEvent", "windowID");
  E.sdl_scancode = off("SDL_KeyboardEvent", "scancode");
  E.sdl_key = off("SDL_KeyboardEvent", "key");
  E.sdl_mod = off("SDL_KeyboardEvent", "mod");
  E.sdl_down = off("SDL_KeyboardEvent", "down");
  E.sdl_repeat = off("SDL_KeyboardEvent", "repeat");
  E.sdl_text_window = off("SDL_TextInputEvent", "windowID");
  E.sdl_text = off("SDL_TextInputEvent", "text");
  E.window_sdl = off("SDLWindow", "window");
  return ok;
}

template <typename T>
static T& field(void* base, size_t off) {
  return *reinterpret_cast<T*>(reinterpret_cast<char*>(base) + off);
}

static std::atomic<void*> g_sdl_window;  // SDL_Window*, captured from the first pollEvent
using PollEvent_t = bool (*)(void*, void*);
static PollEvent_t PollEvent_orig;
static bool PollEvent_hook(void* self, void* ev) {
  if (!g_sdl_window) g_sdl_window = field<void*>(self, E.window_sdl);
  for (;;) {
    if (!PollEvent_orig(self, ev)) return false;
    int type = field<int>(ev, E.type);
    if (type >= 14 && type <= 24) log::writef("event: window event {}", type);  // Event::Type WINDOW_*
    if (type < kKeyDown || type > kKeyComposition) return true;
    // Every key is recorded (a screen that lent the keyboard to the game still watches for the keys that end
    // the loan); it is only swallowed while the native UI owns the keyboard.
    bool swallow = input::owned() || (type != kKeyChar && type != kKeyComposition && input::reserved(field<int>(ev, E.kb_scancode)));
    if (type == kKeyChar) {
      char32_t c = (char32_t)field<int>(ev, E.kb_unichar);
      input::record_text(std::u32string_view(&c, 1));
    } else if (type != kKeyComposition) {
      uint16_t mod = field<uint16_t>(ev, E.kb_mod);
      input::record_key({field<int>(ev, E.kb_scancode), type == kKeyDown, field<bool>(ev, E.kb_repeat), (mod & kModShift) != 0,
                         (mod & kModCtrl) != 0, (mod & kModAlt) != 0});
    }
    if (!swallow) return true;
  }
}

using PushEvent_t = bool (*)(void*);
using GetWindowID_t = uint32_t (*)(void*);
using GetKeyFromScancode_t = uint32_t (*)(int, uint16_t, bool);
static PushEvent_t g_push_event;
static GetWindowID_t g_get_window_id;
static GetKeyFromScancode_t g_key_from_scancode;

// SDL updates its modifier state only for physical keys, so a pushed Ctrl+A arrives as a bare A to code that asks
// SDL_GetModState. While a synthetic key is held, its modifiers are added to the answer.
static std::atomic<uint16_t> g_synthetic_mod;
using GetModState_t = uint16_t (*)();
static GetModState_t GetModState_orig;
static uint16_t GetModState_hook() { return GetModState_orig() | g_synthetic_mod.load(); }

bool push_key(int scancode, bool down, bool shift, bool ctrl, bool alt) {
  void* win = g_sdl_window;
  if (!win || !g_push_event) return false;
  alignas(8) unsigned char ev[128] = {};  // sizeof(SDL_Event)
  uint16_t mod = (shift ? 0x0001 : 0) | (ctrl ? 0x0040 : 0) | (alt ? 0x0100 : 0);  // the left-hand modifier bits
  g_synthetic_mod = down ? mod : 0;
  field<uint32_t>(ev, E.sdl_type) = down ? kSdlKeyDown : kSdlKeyUp;
  field<uint32_t>(ev, E.sdl_window) = g_get_window_id(win);
  field<int>(ev, E.sdl_scancode) = scancode;
  field<uint32_t>(ev, E.sdl_key) = g_key_from_scancode(scancode, mod, false);
  field<uint16_t>(ev, E.sdl_mod) = mod;
  field<bool>(ev, E.sdl_down) = down;
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
  field<uint32_t>(ev, E.sdl_type) = kSdlTextInput;
  field<uint32_t>(ev, E.sdl_text_window) = g_get_window_id(win);
  field<const char*>(ev, E.sdl_text) = text;
  return g_push_event(ev);
}

// ======================= Lua: each mod's control-stage state =======================
// LuaGameScript's constructor (one per mod, plus the scenario) is the only control-stage caller of
// LuaHelper::initLuaState; the data stage's LuaDataLoader is the other. The constructor names the mod, so it
// is noted here and handed to fa::lua once the state is initialised -- before the mod's control.lua runs.
thread_local std::string t_creating_mod;

struct MsvcStringView {
  union {
    char buf[16];
    const char* ptr;
  };
  size_t size;
  size_t cap;
  std::string str() const { return std::string(cap > 15 ? ptr : buf, size); }
};

// LuaGameScript::LuaGameScript(std::string const& name, PackagePath const& x4, Mod const*, LuaRemote*,
// LuaCommandProcessor*, LuaSettings*, LuaRCON*, LuaRendering*, LuaPrototypes*, LuaEventRegistrations*,
// Scenario*, Map&): fifteen pointer-sized arguments after `this`.
using LuaGameScriptCtor_t = void* (*)(void*, const MsvcStringView*, void*, void*, void*, void*, void*, void*, void*, void*, void*, void*, void*,
                                      void*, void*, void*);
static LuaGameScriptCtor_t LuaGameScriptCtor_orig;
static size_t g_mod_package, g_package_path;  // Mod::package (unique_ptr<Package>), Package::packagePath_ (std::filesystem::path)

// MSVC std::wstring (std::filesystem::path's only member): 8 inline wchar_t or a heap pointer, size, capacity.
struct MsvcWString {
  union {
    wchar_t buf[8];
    const wchar_t* ptr;
  };
  size_t size;
  size_t cap;
  std::wstring str() const { return std::wstring(cap > 7 ? ptr : buf, size); }
};

// Where FactorioAccess's files are: the engine's own package for the mod (a directory, or the installed zip).
static void note_mod_package(const void* mod) {
  if (!mod) return;
  const void* package = *reinterpret_cast<void* const*>(reinterpret_cast<const char*>(mod) + g_mod_package);
  if (!package) return;
  auto& path = *reinterpret_cast<const MsvcWString*>(reinterpret_cast<const char*>(package) + g_package_path);
  assets::set_package(path.str());
}
static void* LuaGameScriptCtor_hook(void* self, const MsvcStringView* name, void* a2, void* a3, void* a4, void* a5, void* a6, void* a7, void* a8,
                                    void* a9, void* a10, void* a11, void* a12, void* a13, void* a14, void* a15) {
  struct Clear {
    ~Clear() { t_creating_mod.clear(); }  // also when the mod's script fails to load (a C++ exception)
  } clear;
  t_creating_mod = name->str();
  if (t_creating_mod == "mod-FactorioAccess") note_mod_package(a6);  // a6: Mod const*
  return LuaGameScriptCtor_orig(self, name, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15);
}

using InitLuaState_t = void (*)(void*);
static InitLuaState_t InitLuaState_orig;
static void InitLuaState_hook(void* L) {
  InitLuaState_orig(L);
  // Script names are "mod-<mod name>" for mods and "level" for the scenario's own script.
  std::string_view name = t_creating_mod;
  if (name.starts_with("mod-")) lua::on_state_created(L, name.substr(4));
}

// ======================= dev mode: never let the game take the foreground =======================
// FA_NOFOCUS=1 (the dev loop): the game runs visible but never activates itself, so a launch does not
// interrupt the developer's screen reader. The game's own code is told its window is active; everything
// else sees the truth.
static bool g_nofocus = false;

static bool caller_is_game(void* ret) {
  HMODULE m = nullptr;
  GetModuleHandleExW(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT, (LPCWSTR)ret, &m);
  return m && m == GetModuleHandleW(nullptr);
}

using HwndGetter_t = HWND(WINAPI*)();
static HwndGetter_t GetForegroundWindow_orig, GetActiveWindow_orig, GetFocus_orig;
static HWND lie_if_game(HWND real, void* ret) {
  if (g_nofocus && caller_is_game(ret)) {
    if (HWND g = win::game_window()) return g;
  }
  return real;
}
static HWND WINAPI GetForegroundWindow_hook() { return lie_if_game(GetForegroundWindow_orig(), _ReturnAddress()); }
static HWND WINAPI GetActiveWindow_hook() { return lie_if_game(GetActiveWindow_orig(), _ReturnAddress()); }
static HWND WINAPI GetFocus_hook() { return lie_if_game(GetFocus_orig(), _ReturnAddress()); }

static BOOL(WINAPI* SetForegroundWindow_orig)(HWND);
static HWND(WINAPI* SetActiveWindow_orig)(HWND);
static BOOL(WINAPI* BringWindowToTop_orig)(HWND);
static HWND(WINAPI* SetFocus_orig)(HWND);
static BOOL(WINAPI* ShowWindow_orig)(HWND, int);
static BOOL(WINAPI* SetWindowPos_orig)(HWND, HWND, int, int, int, int, UINT);

static BOOL WINAPI SetForegroundWindow_hook(HWND h) {
  if (g_nofocus) {
    log::write("nofocus: blocked SetForegroundWindow");
    return TRUE;
  }
  return SetForegroundWindow_orig(h);
}
static HWND WINAPI SetActiveWindow_hook(HWND h) {
  if (g_nofocus) {
    log::write("nofocus: blocked SetActiveWindow");
    return h;
  }
  return SetActiveWindow_orig(h);
}
static BOOL WINAPI BringWindowToTop_hook(HWND h) {
  if (g_nofocus) {
    log::write("nofocus: blocked BringWindowToTop");
    return TRUE;
  }
  return BringWindowToTop_orig(h);
}
static HWND WINAPI SetFocus_hook(HWND h) {
  if (g_nofocus) {
    log::write("nofocus: blocked SetFocus");
    return h;
  }
  return SetFocus_orig(h);
}
static BOOL WINAPI ShowWindow_hook(HWND h, int cmd) {
  if (g_nofocus && (cmd == SW_SHOW || cmd == SW_SHOWNORMAL || cmd == SW_RESTORE || cmd == SW_SHOWMAXIMIZED || cmd == SW_SHOWDEFAULT)) {
    log::writef("nofocus: ShowWindow({}) -> SW_SHOWNOACTIVATE", cmd);
    cmd = SW_SHOWNOACTIVATE;
  }
  return ShowWindow_orig(h, cmd);
}
static BOOL WINAPI SetWindowPos_hook(HWND h, HWND after, int x, int y, int cx, int cy, UINT f) {
  if (g_nofocus && !(f & SWP_NOACTIVATE)) {
    f |= SWP_NOACTIVATE;
    if (after == HWND_TOPMOST || after == HWND_TOP) f |= SWP_NOZORDER;
  }
  return SetWindowPos_orig(h, after, x, y, cx, cy, f);
}

#define USER32_HOOK(NAME) Hook{user32(#NAME), (void*)&NAME##_hook, (void**)&NAME##_orig, #NAME, false}

bool install() {
  {
    wchar_t v[4];
    g_nofocus = GetEnvironmentVariableW(L"FA_NOFOCUS", v, 4) > 0 && v[0] == L'1';
  }
  if (!resolve_events()) return false;
  {
    auto mp = sym::offset("Mod", "package"), pp = sym::offset("Package", "packagePath_");
    if (!mp || !pp) return false;
    g_mod_package = *mp;
    g_package_path = *pp;
  }
  g_push_event = sym::fn<PushEvent_t>("SDL_PushEvent_REAL");
  g_get_window_id = sym::fn<GetWindowID_t>("SDL_GetWindowID_REAL");
  g_key_from_scancode = sym::fn<GetKeyFromScancode_t>("SDL_GetKeyFromScancode_REAL");
  if (!g_push_event || !g_get_window_id || !g_key_from_scancode) return false;
  g_hooks = {
      Hook{sym::addr("MainLoop::mainLoopStep"), (void*)&MainLoopStep_hook, (void**)&MainLoopStep_orig, "MainLoop::mainLoopStep", false},
      Hook{sym::addr("SDLWindow::pollEvent"), (void*)&PollEvent_hook, (void**)&PollEvent_orig, "SDLWindow::pollEvent", false},
      Hook{sym::addr("LuaGameScript::LuaGameScript"), (void*)&LuaGameScriptCtor_hook, (void**)&LuaGameScriptCtor_orig, "LuaGameScript::LuaGameScript", false},
      Hook{sym::addr("SDL_GetModState_REAL"), (void*)&GetModState_hook, (void**)&GetModState_orig, "SDL_GetModState", false},
      Hook{sym::addr("LuaHelper::initLuaState"), (void*)&InitLuaState_hook, (void**)&InitLuaState_orig, "LuaHelper::initLuaState", false},
  };
  if (g_nofocus) {
    for (Hook h : {USER32_HOOK(SetForegroundWindow), USER32_HOOK(SetActiveWindow), USER32_HOOK(BringWindowToTop), USER32_HOOK(SetFocus),
                   USER32_HOOK(ShowWindow), USER32_HOOK(SetWindowPos), USER32_HOOK(GetForegroundWindow), USER32_HOOK(GetActiveWindow),
                   USER32_HOOK(GetFocus)})
      g_hooks.push_back(h);
  }
  attach_all();
  for (auto& h : g_hooks)
    if (!h.ok) return false;
  return true;
}

void remove() {
  DetourTransactionBegin();
  {
    ThreadUpdater threads;
    for (auto& h : g_hooks)
      if (h.ok) {
        DetourDetach(h.orig, h.detour);
        h.ok = false;
      }
    DetourTransactionCommit();
  }
}
}  // namespace fa::hooks
