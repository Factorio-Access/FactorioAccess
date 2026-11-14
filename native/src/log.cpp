#include "log.h"
#ifdef _WIN32
#include <windows.h>
#else
#include <sys/time.h>
#include <filesystem>
#include <ctime>
#endif
#include <cstdio>
#include <cstdlib>
#include <mutex>

namespace fa::log {
static FILE* g_file;
static std::mutex g_mu;
static std::wstring g_path;
static LineRing g_ring(2000);

std::wstring path() { return g_path; }
LineRing& ring() { return g_ring; }

#ifdef _WIN32
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

static std::string stamp(std::string_view line) {
  SYSTEMTIME t;
  GetLocalTime(&t);
  return std::format("{:02}:{:02}:{:02}.{:03} {}", t.wHour, t.wMinute, t.wSecond, t.wMilliseconds, line);
}
#else
void init() {
  // ~/Library/Logs/FactorioAccess, where Console.app finds it.
  const char* home = std::getenv("HOME");
  std::filesystem::path dir = std::filesystem::path(home ? home : "/tmp") / "Library/Logs/FactorioAccess";
  std::error_code ec;
  std::filesystem::create_directories(dir, ec);
  bool dev = std::getenv("FA_PORT") != nullptr;
  std::filesystem::path p = dir / (dev ? "native-dev.log" : "native.log");
  g_path = p.wstring();
  g_file = std::fopen(p.c_str(), "w");
}

static std::string stamp(std::string_view line) {
  timeval tv;
  gettimeofday(&tv, nullptr);
  tm t;
  localtime_r(&tv.tv_sec, &t);
  return std::format("{:02}:{:02}:{:02}.{:03} {}", t.tm_hour, t.tm_min, t.tm_sec, (int)(tv.tv_usec / 1000), line);
}
#endif

void write(std::string_view line) {
  std::string stamped = stamp(line);
  g_ring.push(stamped);
  std::lock_guard lk(g_mu);
  if (!g_file) return;
  fprintf(g_file, "%s\n", stamped.c_str());
  fflush(g_file);
}
}  // namespace fa::log
