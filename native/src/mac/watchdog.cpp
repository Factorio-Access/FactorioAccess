#include "watchdog.h"
#include <mach/mach.h>
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

// Never destroyed: the game exits through exit(), and a joinable std::thread destroyed then calls std::terminate.
std::thread* g_thread;
std::mutex g_mu;
std::condition_variable g_cv;
bool g_stop = false;

// The Mach port of the thread whose pthread_threadid_np is `tid`, or 0.
thread_act_t port_of(unsigned long tid) {
  thread_act_array_t threads;
  mach_msg_type_number_t count = 0;
  if (task_threads(mach_task_self(), &threads, &count) != KERN_SUCCESS) return 0;
  thread_act_t found = 0;
  for (mach_msg_type_number_t i = 0; i < count; ++i) {
    thread_identifier_info_data_t info;
    mach_msg_type_number_t n = THREAD_IDENTIFIER_INFO_COUNT;
    if (!found && thread_info(threads[i], THREAD_IDENTIFIER_INFO, (thread_info_t)&info, &n) == KERN_SUCCESS && info.thread_id == tid)
      found = threads[i];
    else
      mach_port_deallocate(mach_task_self(), threads[i]);
  }
  vm_deallocate(mach_task_self(), (vm_address_t)threads, count * sizeof(thread_act_t));
  return found;
}

void dump(unsigned long tid, const char* which) {
  thread_act_t t = port_of(tid);
  if (!t) {
    log::writef("watchdog: cannot find the {} thread", which);
    return;
  }
  std::vector<std::string> frames = sym::thread_stack(reinterpret_cast<void*>((uintptr_t)t));  // suspends and resumes it
  mach_port_deallocate(mach_task_self(), t);
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
  if (g_thread) return;
  g_stop = false;
  g_thread = new std::thread(run);
}

void stop() {
  {
    std::lock_guard lk(g_mu);
    g_stop = true;
  }
  g_cv.notify_all();
  if (g_thread && g_thread->joinable()) g_thread->join();
}
}  // namespace fa::watchdog
