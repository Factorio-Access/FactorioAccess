#include "log.h"
#include <windows.h>
#include <cstdio>
#include <mutex>

namespace fa::log {
static FILE* g_file;
static std::mutex g_mu;
static std::wstring g_path;
static LineRing g_ring(2000);

std::wstring path() { return g_path; }
LineRing& ring() { return g_ring; }

void init() {
  wchar_t base[MAX_PATH];
  DWORD n = GetEnvironmentVariableW(L"LOCALAPPDATA", base, MAX_PATH);
  std::wstring dir = n ? std::wstring(base, n) + L"\\FactorioAccess" : L"C:\\FactorioAccess";
  CreateDirectoryW(dir.c_str(), nullptr);
  // The dev loop (FA_PORT set) logs on its own, so a test game never overwrites a played game's log.
  wchar_t port[8];
  bool dev = GetEnvironmentVariableW(L"FA_PORT", port, 8) > 0;
  g_path = dir + (dev ? L"\\native-dev.log" : L"\\native.log");
  g_file = _wfopen(g_path.c_str(), L"w");
}

void write(std::string_view line) {
  SYSTEMTIME t;
  GetLocalTime(&t);
  std::string stamped = std::format("{:02}:{:02}:{:02}.{:03} {}", t.wHour, t.wMinute, t.wSecond, t.wMilliseconds, line);
  g_ring.push(stamped);
  std::lock_guard lk(g_mu);
  if (!g_file) return;
  fprintf(g_file, "%s\n", stamped.c_str());
  fflush(g_file);
}
}  // namespace fa::log
