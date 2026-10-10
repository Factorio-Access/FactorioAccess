// fa_inject: the dev loop's injector. Process identity (which pid is our game) is the caller's job; this tool
// only acts on the pid it is given.
//   fa_inject --launch <factorio.exe> <dll> [game args...]   start suspended + unfocused, load and init the DLL, resume
//   fa_inject --inject <pid> <dll>                           load and init the DLL in a running game
//   fa_inject --eject <pid> <dll>                            orderly unload (fa_unload, then FreeLibrary)
// Prints "pid <n>" on a successful launch. Exit code 0 on success.
#include <windows.h>
#include <psapi.h>
#include <cstdio>
#include <string>

static HMODULE find_module(HANDLE proc, const wchar_t* fullpath) {
  static HMODULE mods[4096];
  DWORD needed = 0;
  if (!EnumProcessModulesEx(proc, mods, sizeof(mods), &needed, LIST_MODULES_64BIT)) return nullptr;
  for (DWORD i = 0; i < needed / sizeof(HMODULE); ++i) {
    wchar_t name[MAX_PATH];
    if (GetModuleFileNameExW(proc, mods[i], name, MAX_PATH) && !_wcsicmp(name, fullpath)) return mods[i];
  }
  return nullptr;
}

// Run `fn(arg)` on a remote thread and wait for it. Returns the thread's exit code, or 0 on failure/timeout.
static DWORD remote_thread(HANDLE proc, LPTHREAD_START_ROUTINE fn, LPVOID arg, const char* what) {
  HANDLE t = CreateRemoteThread(proc, nullptr, 0, fn, arg, 0, nullptr);
  if (!t) {
    printf("%s: CreateRemoteThread failed: %lu\n", what, GetLastError());
    return 0;
  }
  DWORD w = WaitForSingleObject(t, 30000);
  DWORD code = 0;
  GetExitCodeThread(t, &code);
  CloseHandle(t);
  if (w != WAIT_OBJECT_0) {
    printf("%s: timed out\n", what);
    return 0;
  }
  printf("%s returned 0x%lx\n", what, code);
  return code;
}

// Address of an export of `dll` inside the target, given where the target mapped it (same image, same RVA).
static LPTHREAD_START_ROUTINE remote_export(HMODULE remote_base, const wchar_t* dll, const char* name) {
  HMODULE local = LoadLibraryExW(dll, nullptr, DONT_RESOLVE_DLL_REFERENCES);
  FARPROC f = local ? GetProcAddress(local, name) : nullptr;
  LPTHREAD_START_ROUTINE r = f ? (LPTHREAD_START_ROUTINE)((uintptr_t)remote_base + ((uintptr_t)f - (uintptr_t)local)) : nullptr;
  if (local) FreeLibrary(local);
  if (!r) printf("export %s not found in the DLL\n", name);
  return r;
}

static bool inject(HANDLE proc, const wchar_t* dll) {
  if (find_module(proc, dll)) {
    printf("already loaded; eject first\n");
    return false;
  }
  SIZE_T bytes = (wcslen(dll) + 1) * sizeof(wchar_t);
  LPVOID mem = VirtualAllocEx(proc, nullptr, bytes, MEM_COMMIT, PAGE_READWRITE);
  if (!mem) {
    printf("VirtualAllocEx failed: %lu\n", GetLastError());
    return false;
  }
  WriteProcessMemory(proc, mem, dll, bytes, nullptr);
  auto load = (LPTHREAD_START_ROUTINE)GetProcAddress(GetModuleHandleW(L"kernel32.dll"), "LoadLibraryW");
  remote_thread(proc, load, mem, "LoadLibraryW");
  VirtualFreeEx(proc, mem, 0, MEM_RELEASE);
  HMODULE m = find_module(proc, dll);
  if (!m) {
    printf("the DLL did not load\n");
    return false;
  }
  auto init = remote_export(m, dll, "fa_init");
  return init && remote_thread(proc, init, nullptr, "fa_init") == 1;
}

static bool eject(HANDLE proc, const wchar_t* dll) {
  HMODULE m = find_module(proc, dll);
  if (!m) {
    printf("module not loaded in target\n");
    return false;
  }
  if (auto unload = remote_export(m, dll, "fa_unload")) remote_thread(proc, unload, nullptr, "fa_unload");
  auto free_lib = (LPTHREAD_START_ROUTINE)GetProcAddress(GetModuleHandleW(L"kernel32.dll"), "FreeLibrary");
  return remote_thread(proc, free_lib, m, "FreeLibrary") != 0;
}

static int launch(int argc, wchar_t** argv) {
  const wchar_t* exe = argv[2];
  wchar_t dll[MAX_PATH];
  GetFullPathNameW(argv[3], MAX_PATH, dll, nullptr);
  std::wstring cmd = L"\"" + std::wstring(exe) + L"\"";
  for (int i = 4; i < argc; ++i) cmd += L" \"" + std::wstring(argv[i]) + L"\"";
  // Visible but never activated; the DLL's FA_NOFOCUS hooks stop the game's own activation attempts.
  STARTUPINFOW si{};
  si.cb = sizeof(si);
  si.dwFlags = STARTF_USESHOWWINDOW;
  si.wShowWindow = SW_SHOWNOACTIVATE;
  PROCESS_INFORMATION pi{};
  if (!CreateProcessW(exe, cmd.data(), nullptr, nullptr, FALSE, CREATE_SUSPENDED, nullptr, nullptr, &si, &pi)) {
    printf("CreateProcess failed: %lu\n", GetLastError());
    return 1;
  }
  bool ok = inject(pi.hProcess, dll);
  if (!ok) {
    printf("injection failed; terminating the suspended game\n");
    TerminateProcess(pi.hProcess, 1);
  } else {
    ResumeThread(pi.hThread);
    printf("pid %lu\n", pi.dwProcessId);
  }
  CloseHandle(pi.hThread);
  CloseHandle(pi.hProcess);
  return ok ? 0 : 1;
}

int wmain(int argc, wchar_t** argv) {
  if (argc >= 4 && !_wcsicmp(argv[1], L"--launch")) return launch(argc, argv);
  if (argc == 4 && (!_wcsicmp(argv[1], L"--inject") || !_wcsicmp(argv[1], L"--eject"))) {
    DWORD pid = wcstoul(argv[2], nullptr, 10);
    wchar_t dll[MAX_PATH];
    GetFullPathNameW(argv[3], MAX_PATH, dll, nullptr);
    HANDLE proc = OpenProcess(PROCESS_ALL_ACCESS, FALSE, pid);
    if (!proc) {
      printf("OpenProcess(%lu) failed: %lu\n", pid, GetLastError());
      return 1;
    }
    bool ok = !_wcsicmp(argv[1], L"--inject") ? inject(proc, dll) : eject(proc, dll);
    CloseHandle(proc);
    return ok ? 0 : 1;
  }
  printf("usage: fa_inject --launch <exe> <dll> [args...] | --inject <pid> <dll> | --eject <pid> <dll>\n");
  return 2;
}
