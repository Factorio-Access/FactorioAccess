#include "clipboard.h"
#include <windows.h>
#include <atomic>
#include <mutex>
#include <string>
#include "log.h"

namespace fa::clipboard {
namespace {
constexpr UINT kSet = WM_APP + 1;
constexpr wchar_t kClass[] = L"FactorioAccessClipboard";

// A raw thread handle rather than std::thread: the game exits without fa_unload, and a joinable std::thread destroyed
// at process exit would call std::terminate.
HANDLE g_worker = nullptr;
HANDLE g_ready = nullptr;
std::atomic<HWND> g_hwnd;  // message-only; set by the worker before g_ready
std::mutex g_mu;
std::string g_pending;  // the latest text, taken by the worker (under g_mu); a newer copy replaces an unsent one
bool g_has_pending = false;

std::wstring to_clipboard_text(std::string_view utf8) {
  std::string crlf;
  crlf.reserve(utf8.size());
  for (size_t i = 0; i < utf8.size(); i++) {
    if (utf8[i] == '\n' && (i == 0 || utf8[i - 1] != '\r')) crlf += '\r';
    crlf += utf8[i];
  }
  int n = MultiByteToWideChar(CP_UTF8, 0, crlf.data(), (int)crlf.size(), nullptr, 0);
  std::wstring w(n, L'\0');
  MultiByteToWideChar(CP_UTF8, 0, crlf.data(), (int)crlf.size(), w.data(), n);
  return w;
}

void put(HWND owner, const std::wstring& text) {
  // Another program may hold the clipboard for a moment.
  bool open = false;
  for (int i = 0; i < 20 && !(open = OpenClipboard(owner) != 0); i++) Sleep(25);
  if (!open) {
    log::writef("clipboard: could not open it ({})", GetLastError());
    return;
  }
  EmptyClipboard();
  HGLOBAL mem = GlobalAlloc(GMEM_MOVEABLE, (text.size() + 1) * sizeof(wchar_t));
  bool ok = false;
  if (mem) {
    if (void* p = GlobalLock(mem)) {
      memcpy(p, text.c_str(), (text.size() + 1) * sizeof(wchar_t));
      GlobalUnlock(mem);
      ok = SetClipboardData(CF_UNICODETEXT, mem) != nullptr;
    }
    if (!ok) GlobalFree(mem);  // the clipboard owns it only once SetClipboardData succeeds
  }
  CloseClipboard();
  if (!ok) log::writef("clipboard: could not set the text ({})", GetLastError());
}

LRESULT CALLBACK wndproc(HWND h, UINT msg, WPARAM w, LPARAM l) {
  if (msg == kSet) {
    std::string text;
    {
      std::lock_guard lock(g_mu);
      if (!g_has_pending) return 0;
      text.swap(g_pending);
      g_has_pending = false;
    }
    put(h, to_clipboard_text(text));
    return 0;
  }
  if (msg == WM_DESTROY) {
    PostQuitMessage(0);
    return 0;
  }
  return DefWindowProcW(h, msg, w, l);
}

DWORD WINAPI run(LPVOID) {
  WNDCLASSW wc{};
  wc.lpfnWndProc = wndproc;
  wc.hInstance = GetModuleHandleW(nullptr);
  wc.lpszClassName = kClass;
  RegisterClassW(&wc);
  HWND h = CreateWindowW(kClass, L"", 0, 0, 0, 0, 0, HWND_MESSAGE, nullptr, wc.hInstance, nullptr);
  if (!h) log::writef("clipboard: no window ({})", GetLastError());
  g_hwnd = h;
  SetEvent(g_ready);
  if (!h) return 0;
  MSG msg;
  while (GetMessageW(&msg, nullptr, 0, 0) > 0) DispatchMessageW(&msg);
  UnregisterClassW(kClass, wc.hInstance);
  return 0;
}
}  // namespace

void start() {
  if (g_worker) return;
  g_ready = CreateEventW(nullptr, TRUE, FALSE, nullptr);
  g_worker = CreateThread(nullptr, 0, run, nullptr, 0, nullptr);
  WaitForSingleObject(g_ready, INFINITE);
}

void set_text(std::string_view utf8) {
  {
    std::lock_guard lock(g_mu);
    g_pending.assign(utf8);
    g_has_pending = true;
  }
  if (HWND h = g_hwnd) PostMessageW(h, kSet, 0, 0);
}

void shutdown() {
  if (!g_worker) return;
  if (HWND h = g_hwnd) PostMessageW(h, WM_CLOSE, 0, 0);  // DefWindowProc destroys it, WM_DESTROY ends the loop
  WaitForSingleObject(g_worker, INFINITE);
  CloseHandle(g_worker);
  CloseHandle(g_ready);
  g_worker = g_ready = nullptr;
  g_hwnd = nullptr;
}
}  // namespace fa::clipboard
