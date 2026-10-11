#include "update_check.h"
#include <windows.h>
#include <winhttp.h>
#include <atomic>
#include <mutex>
#include <string>
#include "fa_version.h"
#include "log.h"
#include "speech.h"
#include "update/check.h"

namespace fa::update {
namespace {
constexpr size_t kMaxBody = 1 << 20;
// A raw thread handle rather than std::thread: the game exits without fa_unload, and a joinable std::thread destroyed
// at process exit would call std::terminate.
HANDLE g_worker = nullptr;
std::mutex g_mu;
HINTERNET g_request = nullptr;  // the request in flight (closing it from shutdown() aborts the blocking calls)
std::atomic<bool> g_cancel{false};
std::string g_pending;  // the line to speak, set by the worker, taken by tick() (under g_mu)
Settle g_settle;

std::wstring widen(std::string_view s) { return std::wstring(s.begin(), s.end()); }  // ASCII paths and versions

// GET https://api.github.com<path>; the body, or "" on any failure (logged).
std::string fetch(const std::string& path) {
  std::wstring agent = L"FactorioAccess/" + widen(kVersion);
  HINTERNET session = WinHttpOpen(agent.c_str(), WINHTTP_ACCESS_TYPE_AUTOMATIC_PROXY, WINHTTP_NO_PROXY_NAME, WINHTTP_NO_PROXY_BYPASS, 0);
  if (!session) {
    log::writef("update: WinHttpOpen failed ({})", GetLastError());
    return {};
  }
  WinHttpSetTimeouts(session, 5000, 5000, 10000, 10000);
  // FA_UPDATE_HOST (dev) replaces the host, e.g. "nonexistent.invalid" to exercise the offline path.
  wchar_t host[256] = L"api.github.com";
  DWORD n = GetEnvironmentVariableW(L"FA_UPDATE_HOST", host, 256);
  if (n == 0 || n >= 256) wcscpy_s(host, L"api.github.com");
  HINTERNET connect = WinHttpConnect(session, host, INTERNET_DEFAULT_HTTPS_PORT, 0);
  HINTERNET request = connect ? WinHttpOpenRequest(connect, L"GET", widen(path).c_str(), nullptr, WINHTTP_NO_REFERER,
                                                   WINHTTP_DEFAULT_ACCEPT_TYPES, WINHTTP_FLAG_SECURE)
                              : nullptr;
  std::string body;
  DWORD status = 0;
  if (request) {
    std::lock_guard l(g_mu);
    if (g_cancel) {
      WinHttpCloseHandle(request);
      request = nullptr;
    } else {
      g_request = request;
    }
  }
  if (request) {
    const wchar_t* headers = L"Accept: application/vnd.github+json\r\nX-GitHub-Api-Version: 2022-11-28\r\n";
    bool ok = WinHttpSendRequest(request, headers, (DWORD)-1, WINHTTP_NO_REQUEST_DATA, 0, 0, 0) && WinHttpReceiveResponse(request, nullptr);
    DWORD size = sizeof status;
    if (ok)
      ok = WinHttpQueryHeaders(request, WINHTTP_QUERY_STATUS_CODE | WINHTTP_QUERY_FLAG_NUMBER, WINHTTP_HEADER_NAME_BY_INDEX, &status, &size,
                               WINHTTP_NO_HEADER_INDEX);
    while (ok && !g_cancel) {
      DWORD avail = 0;
      if (!WinHttpQueryDataAvailable(request, &avail) || avail == 0) break;
      size_t at = body.size();
      if (at + avail > kMaxBody) {
        body.clear();
        break;
      }
      body.resize(at + avail);
      DWORD got = 0;
      if (!WinHttpReadData(request, body.data() + at, avail, &got)) {
        body.clear();
        break;
      }
      body.resize(at + got);
    }
    if (!ok) log::writef("update: request failed ({})", GetLastError());
    std::lock_guard l(g_mu);
    if (g_request) {  // else shutdown() closed it
      WinHttpCloseHandle(g_request);
      g_request = nullptr;
    }
  }
  if (connect) WinHttpCloseHandle(connect);
  WinHttpCloseHandle(session);
  if (status != 200) {
    if (status) log::writef("update: GitHub answered {} for {}", status, path);
    return {};
  }
  return body;
}

DWORD WINAPI run(LPVOID) {
  std::string_view mine = kVersion;
  std::string body = fetch(request_path(channel_of(mine)));
  if (g_cancel || body.empty()) return 0;
  Verdict v = decide(mine, body);
  log::writef("update: installed {}, newer={} latest='{}'", mine, v.newer, v.latest);
  if (!v.newer) return 0;
  std::string line = announcement(mine, v);
  std::lock_guard l(g_mu);
  g_pending = std::move(line);  // spoken by tick() once the main menu has settled
  return 0;
}
}  // namespace

void tick(bool on_main_menu, double now) {
  if (!g_settle.ready(on_main_menu, now)) return;
  std::string line;
  {
    std::lock_guard l(g_mu);
    line.swap(g_pending);
  }
  if (line.empty()) return;
  log::write("update: announced on the main menu");
  speech::speak(line, false);
}

void start() {
  log::writef("fa_native: version {}", kVersion);
  if (channel_of(kVersion) == Channel::None || g_worker) return;
  g_cancel = false;
  g_worker = CreateThread(nullptr, 0, run, nullptr, 0, nullptr);
}

void shutdown() {
  g_cancel = true;
  {
    std::lock_guard l(g_mu);
    if (g_request) {
      WinHttpCloseHandle(g_request);
      g_request = nullptr;
    }
  }
  if (g_worker) {
    WaitForSingleObject(g_worker, INFINITE);
    CloseHandle(g_worker);
    g_worker = nullptr;
  }
}
}  // namespace fa::update
