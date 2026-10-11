#include "watchdog.h"
#include <windows.h>
#include <atomic>
#include <chrono>
#include <condition_variable>
#include <mutex>
#include <thread>
#include "game.h"
#include "hooks.h"
#include "log.h"
#include "lua_native.h"
#include "sym.h"

namespace fa::watchdog {
namespace {
constexpr auto kStall = std::chrono::seconds(5);
constexpr auto kRepeat = std::chrono::seconds(30);

std::thread g_thread;
std::mutex g_mu;
std::condition_variable g_cv;
bool g_stop = false;

void dump(unsigned long tid, const char* which) {
  HANDLE h = OpenThread(THREAD_SUSPEND_RESUME | THREAD_GET_CONTEXT | THREAD_QUERY_INFORMATION, FALSE, tid);
  if (!h) {
    log::writef("watchdog: cannot open the main thread: {}", GetLastError());
    return;
  }
  std::vector<std::string> frames = sym::thread_stack(h);  // suspends and resumes it
  CloseHandle(h);
  log::writef("watchdog: {} thread stack:", which);
  for (const std::string& f : frames) log::writef("  {}", f);
}

void report(unsigned long tid) {
  dump(tid, "main");
  // Scripts run on the game's update thread, which the main loop waits for: a hang in native code a script called
  // shows only there.
  unsigned long script = lua::script_thread_id();
  if (script && script != tid) dump(script, "script");
  // A loop in the mod's Lua shows here only as the VM: ask the VM itself where it is.
  if (game::in_game()) lua::request_traceback();
}

void run() {
  uint64_t last = hooks::frame();
  auto since = std::chrono::steady_clock::now();
  auto reported = since;
  bool stalled = false;
  std::unique_lock lk(g_mu);
  while (!g_cv.wait_for(lk, std::chrono::seconds(1), [] { return g_stop; })) {
    auto now = std::chrono::steady_clock::now();
    uint64_t f = hooks::frame();
    unsigned long tid = hooks::main_thread_id();
    if (f != last || tid == 0) {
      if (stalled) log::writef("watchdog: frames again after {} s", std::chrono::duration_cast<std::chrono::seconds>(now - since).count());
      last = f;
      since = now;
      stalled = false;
      continue;
    }
    if (now - since < kStall || (stalled && now - reported < kRepeat)) continue;
    log::writef("watchdog: no frame for {} s", std::chrono::duration_cast<std::chrono::seconds>(now - since).count());
    stalled = true;
    reported = now;
    report(tid);
  }
}
}  // namespace

void report_now() {
  if (unsigned long tid = hooks::main_thread_id()) report(tid);
}

void start() {
  g_stop = false;
  g_thread = std::thread(run);
}

void stop() {
  {
    std::lock_guard lk(g_mu);
    g_stop = true;
  }
  g_cv.notify_all();
  if (g_thread.joinable()) g_thread.join();
}
}  // namespace fa::watchdog
