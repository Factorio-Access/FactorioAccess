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
// A frame this late is reported (stacks and a Lua traceback), at most once per kRepeat; any gap of a second or more is
// logged with its length once frames come back. Lag that never stops frames entirely still makes Windows call the
// game "not responding".
constexpr auto kStall = std::chrono::seconds(2);
constexpr auto kRepeat = std::chrono::seconds(10);
constexpr auto kNoteGap = std::chrono::seconds(1);

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
  using namespace std::chrono;
  uint64_t last_frame = hooks::frame();
  auto since = steady_clock::now();
  auto reported = since - kRepeat;
  std::unique_lock lk(g_mu);
  while (!g_cv.wait_for(lk, milliseconds(250), [] { return g_stop; })) {
    auto now = steady_clock::now();
    uint64_t f = hooks::frame();
    unsigned long tid = hooks::main_thread_id();
    if (f != last_frame || tid == 0) {
      if (now - since >= kNoteGap) log::writef("watchdog: a frame took {} ms", duration_cast<milliseconds>(now - since).count());
      last_frame = f;
      since = now;
      continue;
    }
    if (now - since < kStall || now - reported < kRepeat) continue;
    log::writef("watchdog: no frame for {} ms", duration_cast<milliseconds>(now - since).count());
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
