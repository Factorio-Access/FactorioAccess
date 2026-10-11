#pragma once
// The update check: once per load, on a thread of its own, ask GitHub whether a newer release (or, for a CI build, a
// newer CI build) exists than the version embedded in this DLL, and say so once the main menu is up. Silent on a dev
// build, offline and on any error. It never blocks the game and never touches Lua: the main thread only takes a
// finished line. Decisions in update/check.h.
namespace fa::update {
void start();  // after the native code is up; no-op for a dev build
// Per frame (main thread): speaks the result once the main menu has been current for a few seconds. A player who
// skips the main menu (--load-game, --mp-connect) is simply not told until they reach it.
void tick(bool on_main_menu, double now);
void shutdown();  // cancels a request in flight and waits for the thread (fa_unload, never DllMain)
}  // namespace fa::update
