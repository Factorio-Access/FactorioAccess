#include "win/window.h"

namespace fa::win {
static HWND g_hwnd;

static BOOL CALLBACK find(HWND h, LPARAM) {
  DWORD pid = 0;
  GetWindowThreadProcessId(h, &pid);
  if (pid != GetCurrentProcessId() || !IsWindowVisible(h) || GetWindowTextLengthW(h) == 0) return TRUE;
  g_hwnd = h;
  return FALSE;
}

HWND game_window() {
  if (!g_hwnd || !IsWindow(g_hwnd)) {
    g_hwnd = nullptr;
    EnumWindows(find, 0);
  }
  return g_hwnd;
}
}  // namespace fa::win
