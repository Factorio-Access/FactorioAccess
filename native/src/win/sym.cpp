#include "sym.h"
#include <windows.h>
#include <dbghelp.h>
#include <mutex>
#include <string>
#include <vector>
#include "log.h"

namespace fa::sym {
// dbghelp is single-threaded by contract; every call goes through this lock.
static std::mutex g_mu;
static HANDLE g_proc;
// SymTagEnum values (cvconst.h, which ships with the DIA SDK rather than the Windows SDK).
constexpr DWORD kSymTagFunction = 5, kSymTagData = 7, kSymTagBaseClass = 18;
static DWORD64 g_base;

bool init() {
  std::lock_guard lk(g_mu);
  g_proc = GetCurrentProcess();
  SymSetOptions(SYMOPT_DEFERRED_LOADS | SYMOPT_FAIL_CRITICAL_ERRORS | SYMOPT_NO_PROMPTS);
  // Search only next to the exe: never the symbol server, never _NT_SYMBOL_PATH.
  wchar_t exe[MAX_PATH];
  GetModuleFileNameW(nullptr, exe, MAX_PATH);
  std::wstring dir(exe);
  dir = dir.substr(0, dir.find_last_of(L'\\'));
  if (!SymInitializeW(g_proc, dir.c_str(), FALSE)) {
    log::writef("sym: SymInitialize failed: {}", GetLastError());
    return false;
  }
  g_base = (DWORD64)GetModuleHandleW(nullptr);
  if (!SymLoadModuleExW(g_proc, nullptr, exe, nullptr, g_base, 0, nullptr, 0)) {
    log::writef("sym: SymLoadModuleEx failed: {}", GetLastError());
    return false;
  }
  // Loads are deferred: a lookup forces the PDB in, and proves it is the full (private) one.
  alignas(SYMBOL_INFO) char buf[sizeof(SYMBOL_INFO) + MAX_SYM_NAME];
  auto* si = reinterpret_cast<SYMBOL_INFO*>(buf);
  si->SizeOfStruct = sizeof(SYMBOL_INFO);
  si->MaxNameLen = MAX_SYM_NAME;
  if (!SymFromName(g_proc, "luaD_throw", si)) {
    log::writef("sym: factorio.pdb missing or stripped (no luaD_throw): {}", GetLastError());
    return false;
  }
  log::write("sym: factorio.pdb loaded");
  return true;
}

void shutdown() {
  std::lock_guard lk(g_mu);
  SymCleanup(g_proc);
}

void* addr(const char* name) {
  std::lock_guard lk(g_mu);
  alignas(SYMBOL_INFO) char buf[sizeof(SYMBOL_INFO) + MAX_SYM_NAME];
  auto* si = reinterpret_cast<SYMBOL_INFO*>(buf);
  si->SizeOfStruct = sizeof(SYMBOL_INFO);
  si->MaxNameLen = MAX_SYM_NAME;
  if (!SymFromName(g_proc, name, si)) {
    log::writef("sym: '{}' not found", name);
    return nullptr;
  }
  return reinterpret_cast<void*>(si->Address);
}

static std::wstring name_of(ULONG type) {
  WCHAR* n = nullptr;
  if (!SymGetTypeInfo(g_proc, g_base, type, TI_GET_SYMNAME, &n) || !n) return {};
  std::wstring s(n);
  LocalFree(n);
  return s;
}

// Children of a UDT: data members and base classes, as type ids.
static std::vector<ULONG> children(ULONG type) {
  DWORD count = 0;
  if (!SymGetTypeInfo(g_proc, g_base, type, TI_GET_CHILDRENCOUNT, &count) || !count) return {};
  std::vector<char> buf(sizeof(TI_FINDCHILDREN_PARAMS) + count * sizeof(ULONG));
  auto* p = reinterpret_cast<TI_FINDCHILDREN_PARAMS*>(buf.data());
  p->Count = count;
  p->Start = 0;
  if (!SymGetTypeInfo(g_proc, g_base, type, TI_FINDCHILDREN, p)) return {};
  return std::vector<ULONG>(p->ChildId, p->ChildId + count);
}

static std::optional<std::size_t> find_member(ULONG type, const std::wstring& member) {
  for (ULONG c : children(type)) {
    DWORD tag = 0;
    SymGetTypeInfo(g_proc, g_base, c, TI_GET_SYMTAG, &tag);
    DWORD off = 0;
    if (tag == kSymTagData && name_of(c) == member && SymGetTypeInfo(g_proc, g_base, c, TI_GET_OFFSET, &off)) return off;
    if (tag == kSymTagBaseClass) {
      ULONG base_type = 0;
      SymGetTypeInfo(g_proc, g_base, c, TI_GET_TYPEID, &base_type);
      if (auto r = find_member(base_type, member)) {
        SymGetTypeInfo(g_proc, g_base, c, TI_GET_OFFSET, &off);
        return *r + off;
      }
    }
  }
  return std::nullopt;
}

static std::optional<ULONG> type_id(const char* type) {
  alignas(SYMBOL_INFO) char buf[sizeof(SYMBOL_INFO) + MAX_SYM_NAME];
  auto* si = reinterpret_cast<SYMBOL_INFO*>(buf);
  si->SizeOfStruct = sizeof(SYMBOL_INFO);
  si->MaxNameLen = MAX_SYM_NAME;
  if (!SymGetTypeFromName(g_proc, g_base, type, si)) {
    log::writef("sym: type '{}' not found", type);
    return std::nullopt;
  }
  return si->TypeIndex;
}

std::optional<std::size_t> vtable_offset(const char* type, const char* method) {
  std::lock_guard lk(g_mu);
  auto t = type_id(type);
  if (!t) return std::nullopt;
  // Methods carry their qualified name ("agui::Widget::getText"); data members their bare one.
  std::string qualified = std::string(type) + "::" + method;
  std::wstring m(qualified.begin(), qualified.end());
  for (ULONG c : children(*t)) {
    DWORD tag = 0, off = 0;
    SymGetTypeInfo(g_proc, g_base, c, TI_GET_SYMTAG, &tag);
    if (tag == kSymTagFunction && name_of(c) == m && SymGetTypeInfo(g_proc, g_base, c, TI_GET_VIRTUALBASEOFFSET, &off)) return off;
  }
  log::writef("sym: virtual '{}::{}' not found", type, method);
  return std::nullopt;
}

std::optional<std::size_t> offset(const char* type, const char* member) {
  std::lock_guard lk(g_mu);
  auto t = type_id(type);
  if (!t) return std::nullopt;
  std::wstring m(member, member + strlen(member));
  auto r = find_member(*t, m);
  if (!r) log::writef("sym: '{}::{}' not found", type, member);
  return r;
}
}  // namespace fa::sym
