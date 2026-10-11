#pragma once
// Diagnostics for a hung game ("not responding"): when the main loop has not run a frame for a few seconds, log the
// main thread's native stack and ask the mod's Lua for a traceback, so a freeze in play leaves its location in
// native.log.
namespace fa::watchdog {
void start();
void stop();  // joins the thread; never from DllMain
void report_now();  // log the main thread's stack now (dev server)
}  // namespace fa::watchdog
