#include "win/window.h"
#include "mouse.h"

namespace fa::win {
static HWND g_hwnd;

static BOOL CALLBACK find(HWND h, LPARAM) {
  DWORD pid = 0;
  GetWindowThreadProcessId(h, &pid);
  if (pid != GetCurrentProcessId() || !IsWindowVisible(h) || GetWindowTextLengthW(h) == 0) return TRUE;
  g_hwnd = h;
  return FALSE;
}

static bool dev_nofocus() {
  static const bool on = [] {
    wchar_t v[4];
    return GetEnvironmentVariableW(L"FA_NOFOCUS", v, 4) > 0 && v[0] == L'1';
  }();
  return on;
}

HWND game_window() {
  if (!g_hwnd || !IsWindow(g_hwnd)) {
    g_hwnd = nullptr;
    EnumWindows(find, 0);
  }
  return g_hwnd;
}
}  // namespace fa::win

namespace fa::mouse {
void move_to_client(int x, int y) {
  HWND h = fa::win::game_window();
  // The dev loop hooks GetForegroundWindow to keep the game thinking it has focus; never move the developer's mouse.
  if (!h || fa::win::dev_nofocus() || GetForegroundWindow() != h) return;
  POINT p{x, y};
  if (ClientToScreen(h, &p)) SetCursorPos(p.x, p.y);
}
}  // namespace fa::mouse
