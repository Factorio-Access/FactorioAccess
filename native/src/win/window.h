#pragma once
#include <windows.h>

namespace fa::win {
// The game's main window (a visible, titled top-level window of this process), or null before it exists.
HWND game_window();
}  // namespace fa::win
