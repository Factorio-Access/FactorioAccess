#pragma once
// Diagnostics for a hung or lagging game ("not responding"): when the main loop has not run a frame for 2 seconds, log
// the main and script threads' native stacks and ask the mod's Lua for a traceback, so a freeze in play leaves its
// location in native.log.
namespace fa::watchdog {
void start();
void stop();  // joins the thread; never from DllMain
void report_now();  // log the main thread's stack now (dev server)
}  // namespace fa::watchdog
