#include "speech.h"
#include <windows.h>
#include <prism.h>
#include <mutex>
#include <string>
#include "log.h"

namespace fa::speech {
static PrismContext* g_ctx;
static PrismBackend* g_backend;
static std::mutex g_mu;
static bool g_muted = false;
static LineRing g_history(500);

static void prism_log(void*, PrismLogLevel level, const char* source, const char* message) {
  if (level >= PRISM_LOG_LEVEL_INFO) log::writef("[prism:{}] {}", source ? source : "", message ? message : "");
}

bool init() {
  // prism.dll sits next to fa_native.dll, which is not on the game's DLL search path: load it by full path
  // first so the delay-load resolver finds the already-loaded module by name.
  HMODULE self = nullptr;
  GetModuleHandleExW(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT, (LPCWSTR)&init, &self);
  wchar_t dir[MAX_PATH];
  GetModuleFileNameW(self, dir, MAX_PATH);
  std::wstring p(dir);
  p = p.substr(0, p.find_last_of(L'\\') + 1) + L"prism.dll";
  if (!LoadLibraryW(p.c_str())) {
    log::writef("speech: failed to load prism.dll (err {})", GetLastError());
    return false;
  }
  prism_set_log_handler(PrismLogHandler{prism_log, nullptr});
  prism_set_log_level(PRISM_LOG_LEVEL_INFO);
  PrismConfig cfg = prism_config_init();
  g_ctx = prism_init(&cfg);
  if (!g_ctx) { log::write("speech: prism_init failed"); return false; }
  g_backend = prism_registry_create_best(g_ctx);
  if (!g_backend) { log::write("speech: no usable backend"); return false; }
  PrismError e = prism_backend_initialize(g_backend);
  if (e != PRISM_OK && e != PRISM_ERROR_ALREADY_INITIALIZED) {
    log::writef("speech: backend_initialize failed: {}", (int)e);
    return false;
  }
  log::writef("speech: using backend '{}'{}", backend_name(), g_muted ? " (muted)" : "");
  return true;
}

const char* backend_name() { return g_backend ? prism_backend_name(g_backend) : "(none)"; }

void speak(std::string_view utf8, bool interrupt) {
  log::writef("[speak{}] {}", interrupt ? "!" : "", utf8);
  g_history.push(std::string(utf8));
  std::lock_guard lk(g_mu);
  if (!g_backend || g_muted) return;
  std::string s(utf8);
  PrismError e = prism_backend_speak(g_backend, s.c_str(), interrupt);
  if (e != PRISM_OK) log::writef("speech: speak failed: {}", (int)e);
}

void stop() {
  std::lock_guard lk(g_mu);
  if (g_backend && !g_muted) prism_backend_stop(g_backend);
}
void set_muted(bool m) { g_muted = m; }
bool muted() { return g_muted; }
LineRing& history() { return g_history; }

void shutdown() {
  std::lock_guard lk(g_mu);
  if (g_backend) { prism_backend_free(g_backend); g_backend = nullptr; }
  if (g_ctx) { prism_shutdown(g_ctx); g_ctx = nullptr; }
}
}  // namespace fa::speech
