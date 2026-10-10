// version.dll: the player's way in. factorio.exe imports VERSION.dll, which is not a KnownDLL, so this copy next to
// the exe is loaded instead of System32's. Every export forwards to the real one; on load, a thread loads
// fa_native.dll from this same folder and runs its fa_init.
//
// FA_NO_PROXY=1 turns it into a pure forwarder (the dev loop injects its own build of fa_native.dll instead).
#include <windows.h>
#include <string>

#pragma comment(linker, "/export:GetFileVersionInfoA=C:\\Windows\\System32\\version.GetFileVersionInfoA")
#pragma comment(linker, "/export:GetFileVersionInfoByHandle=C:\\Windows\\System32\\version.GetFileVersionInfoByHandle")
#pragma comment(linker, "/export:GetFileVersionInfoExA=C:\\Windows\\System32\\version.GetFileVersionInfoExA")
#pragma comment(linker, "/export:GetFileVersionInfoExW=C:\\Windows\\System32\\version.GetFileVersionInfoExW")
#pragma comment(linker, "/export:GetFileVersionInfoSizeA=C:\\Windows\\System32\\version.GetFileVersionInfoSizeA")
#pragma comment(linker, "/export:GetFileVersionInfoSizeExA=C:\\Windows\\System32\\version.GetFileVersionInfoSizeExA")
#pragma comment(linker, "/export:GetFileVersionInfoSizeExW=C:\\Windows\\System32\\version.GetFileVersionInfoSizeExW")
#pragma comment(linker, "/export:GetFileVersionInfoSizeW=C:\\Windows\\System32\\version.GetFileVersionInfoSizeW")
#pragma comment(linker, "/export:GetFileVersionInfoW=C:\\Windows\\System32\\version.GetFileVersionInfoW")
#pragma comment(linker, "/export:VerFindFileA=C:\\Windows\\System32\\version.VerFindFileA")
#pragma comment(linker, "/export:VerFindFileW=C:\\Windows\\System32\\version.VerFindFileW")
#pragma comment(linker, "/export:VerInstallFileA=C:\\Windows\\System32\\version.VerInstallFileA")
#pragma comment(linker, "/export:VerInstallFileW=C:\\Windows\\System32\\version.VerInstallFileW")
#pragma comment(linker, "/export:VerLanguageNameA=C:\\Windows\\System32\\version.VerLanguageNameA")
#pragma comment(linker, "/export:VerLanguageNameW=C:\\Windows\\System32\\version.VerLanguageNameW")
#pragma comment(linker, "/export:VerQueryValueA=C:\\Windows\\System32\\version.VerQueryValueA")
#pragma comment(linker, "/export:VerQueryValueW=C:\\Windows\\System32\\version.VerQueryValueW")

static HMODULE g_self;

static DWORD WINAPI load_native(LPVOID) {
  wchar_t path[MAX_PATH];
  GetModuleFileNameW(g_self, path, MAX_PATH);
  std::wstring dir(path);
  dir = dir.substr(0, dir.find_last_of(L'\\') + 1);
  HMODULE native = LoadLibraryW((dir + L"fa_native.dll").c_str());
  if (!native) {
    OutputDebugStringW(L"FactorioAccess: fa_native.dll not found next to version.dll\n");
    return 0;
  }
  auto init = reinterpret_cast<LPTHREAD_START_ROUTINE>(GetProcAddress(native, "fa_init"));
  return init ? init(nullptr) : 0;
}

BOOL WINAPI DllMain(HMODULE h, DWORD reason, LPVOID) {
  if (reason != DLL_PROCESS_ATTACH) return TRUE;
  g_self = h;
  DisableThreadLibraryCalls(h);
  wchar_t v[4];
  if (GetEnvironmentVariableW(L"FA_NO_PROXY", v, 4) > 0 && v[0] == L'1') return TRUE;
  // Nothing heavy under the loader lock: the thread starts once the loader is done with this process's imports.
  if (HANDLE t = CreateThread(nullptr, 0, load_native, nullptr, 0, nullptr)) CloseHandle(t);
  return TRUE;
}
