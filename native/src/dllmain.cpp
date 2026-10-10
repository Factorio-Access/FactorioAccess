#include <windows.h>
#include "agui.h"
#include "app.h"
#include "game.h"
#include "devserver.h"
#include "hooks.h"
#include "log.h"
#include "speech.h"
#include "sym.h"

static bool env_flag(const wchar_t* name) {
  wchar_t v[8];
  return GetEnvironmentVariableW(name, v, 8) > 0 && v[0] == L'1';
}
static int env_int(const wchar_t* name, int def) {
  wchar_t v[16];
  return GetEnvironmentVariableW(name, v, 16) > 0 ? _wtoi(v) : def;
}

static bool g_installed = false;

// Called by the injector on a remote thread right after LoadLibrary, while the game's main thread is still
// suspended at a fresh launch, so every hook is in place before the game creates its window.
// Environment (set by the dev loop): FA_MUTE=1 records speech without voicing it, FA_NOFOCUS=1 keeps the
// game from activating its window, FA_PORT=<n> starts the dev server.
extern "C" __declspec(dllexport) DWORD WINAPI fa_init(LPVOID) {
  fa::log::init();
  fa::log::write("fa_native: loaded");
  fa::speech::set_muted(env_flag(L"FA_MUTE"));
  bool sp = fa::speech::init();
  if (!fa::sym::init()) {
    fa::speech::speak("Factorio Access native code could not read the game's symbols and is disabled", true);
    return 0;
  }
  if (!fa::agui::init() || !fa::game::init()) {
    fa::speech::speak("Factorio Access native code does not support this game version and is disabled", true);
    return 0;
  }
  g_installed = fa::hooks::install();
  if (!g_installed) {
    fa::log::write("fa_native: hook install failed; removing what attached");
    fa::hooks::remove();
    fa::speech::speak("Factorio Access native code does not support this game version and is disabled", true);
    return 0;
  }
  fa::app::init();
  fa::hooks::set_frame_callback(fa::app::tick);
  if (int port = env_int(L"FA_PORT", 0)) fa::dev::start(port);
  fa::log::writef("fa_native: ready, speech {}", sp ? fa::speech::backend_name() : "unavailable");
  return 1;
}

// Orderly shutdown, called by the injector on a remote thread before FreeLibrary. Never from DllMain:
// stopping the dev server joins a thread, which deadlocks under the loader lock.
extern "C" __declspec(dllexport) DWORD WINAPI fa_unload(LPVOID) {
  fa::log::write("fa_native: unloading");
  fa::dev::stop();
  if (g_installed) fa::hooks::remove();
  Sleep(250);  // the main thread may still be inside a hook body (the frame callback included): let it leave
  fa::app::shutdown();
  fa::sym::shutdown();
  fa::speech::shutdown();
  // The detours are gone but the main thread may still be inside one of our hook bodies: let it leave.
  Sleep(250);
  fa::log::write("fa_native: ready for FreeLibrary");
  return 1;
}

BOOL WINAPI DllMain(HMODULE h, DWORD reason, LPVOID) {
  if (reason == DLL_PROCESS_ATTACH) DisableThreadLibraryCalls(h);
  return TRUE;
}
