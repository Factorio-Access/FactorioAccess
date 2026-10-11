#pragma once
#include <windows.h>

namespace fa::win {
// The game's main window (a visible, titled top-level window of this process), or null before it exists. Main thread
// only: finding it reads window titles, which sends messages to the windows' threads, and a thread the main thread
// is waiting for (the game's update thread, running scripts) would deadlock with it.
HWND game_window();
// The window game_window() last found, from any thread; null until the main thread has looked.
HWND known_game_window();
}  // namespace fa::win
