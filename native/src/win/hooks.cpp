#include "hooks.h"
#include <windows.h>
#include <detours.h>
#include <intrin.h>
#include <tlhelp32.h>
#include <condition_variable>
#include <deque>
#include <memory>
#include <mutex>
#include <vector>
#include "log.h"
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
static uint64_t g_frame;
uint64_t frame() { return g_frame; }

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
  ++g_frame;
  drain_jobs();
  return MainLoopStep_orig(worker, heavy);
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
  g_hooks = {
      Hook{sym::addr("MainLoop::mainLoopStep"), (void*)&MainLoopStep_hook, (void**)&MainLoopStep_orig, "MainLoop::mainLoopStep", false},
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
