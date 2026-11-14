// fa::hooks on macOS: inline hooks (mac/inline_hook.cpp) on the same game functions the Windows layer detours.
#include "hooks.h"
#include <pthread.h>
#include <atomic>
#include <condition_variable>
#include <deque>
#include <memory>
#include <mutex>
#include <string>
#include <vector>
#include "log.h"
#include "mac/abi.h"
#include "mac/inline_hook.h"
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
int MainLoopStep_hook(void* worker, int heavy) {
  if (!g_main_tid) {
    g_main_tid = tid();
    log::writef("hooks: first frame on thread {}", (unsigned long)g_main_tid);
  }
  ++g_frame;
  drain_jobs();
  if (g_on_frame) g_on_frame();
  return MainLoopStep_orig(worker, heavy);
}

// The mod whose script state is being built on this thread: LuaGameScript's constructor names it, and
// LuaHelper::initLuaState runs inside it.
thread_local std::string t_creating_mod;

// LuaGameScript::LuaGameScript(std::string const& name, PackagePath const& x4, Mod const*, LuaRemote*, ...): the
// base-object constructor (C2), which the complete-object one tail-calls. Fifteen arguments after `this`.
using LuaGameScriptCtor_t = void* (*)(void*, const mac::abi::String*, void*, void*, void*, void*, void*, void*, void*, void*, void*,
                                      void*, void*, void*, void*, void*);
LuaGameScriptCtor_t LuaGameScriptCtor_orig;
void* LuaGameScriptCtor_hook(void* self, const mac::abi::String* name, void* a2, void* a3, void* a4, void* a5, void* a6, void* a7, void* a8,
                             void* a9, void* a10, void* a11, void* a12, void* a13, void* a14, void* a15) {
  struct Clear {
    ~Clear() { t_creating_mod.clear(); }  // also when the mod's script fails to load (a C++ exception)
  } clear;
  t_creating_mod = name->str();
  return LuaGameScriptCtor_orig(self, name, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15);
}

using InitLuaState_t = void (*)(void*);
InitLuaState_t InitLuaState_orig;
void InitLuaState_hook(void* L) {
  InitLuaState_orig(L);
  std::string_view name = t_creating_mod;
  log::writef("hooks: Lua state for '{}'", name);
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
  g_hooks = {
      Hook{sym::addr("MainLoop::mainLoopStep"), (void*)&MainLoopStep_hook, (void**)&MainLoopStep_orig, "MainLoop::mainLoopStep", false},
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

// Synthetic input arrives with the SDL event hook (stage 3 of the port).
bool push_key(int, bool, bool, bool, bool) { return false; }
bool push_text(std::string_view) { return false; }
bool push_mouse_move(float, float) { return false; }
}  // namespace fa::hooks
