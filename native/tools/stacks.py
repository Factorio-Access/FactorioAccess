"""Print every thread's call stack of a running process (a hung Factorio), named through its PDBs.

Usage: python native/tools/stacks.py <pid> [--frames N]

Each thread is paused for the moment its stack is walked (dbghelp's StackWalk64 over the process's memory), then
resumed. Nothing is injected; the process is only read. Windows x64 only.
"""

import argparse
import ctypes
import ctypes.wintypes as wt
import sys

k32 = ctypes.WinDLL("kernel32", use_last_error=True)
dbg = ctypes.WinDLL("dbghelp", use_last_error=True)

PROCESS_ALL = 0x1F0FFF
THREAD_ACCESS = 0x0002 | 0x0008 | 0x0010 | 0x0040  # suspend/resume, get context, set information, query information
TH32CS_SNAPTHREAD = 0x4
CONTEXT_FULL = 0x10000B
IMAGE_FILE_MACHINE_AMD64 = 0x8664
AddrModeFlat = 3


class THREADENTRY32(ctypes.Structure):
    _fields_ = [
        ("dwSize", wt.DWORD),
        ("cntUsage", wt.DWORD),
        ("th32ThreadID", wt.DWORD),
        ("th32OwnerProcessID", wt.DWORD),
        ("tpBasePri", ctypes.c_long),
        ("tpDeltaPri", ctypes.c_long),
        ("dwFlags", wt.DWORD),
    ]


class ADDRESS64(ctypes.Structure):
    _fields_ = [("Offset", ctypes.c_uint64), ("Segment", wt.WORD), ("Mode", ctypes.c_int)]


class KDHELP64(ctypes.Structure):
    _fields_ = [("data", ctypes.c_uint64 * 20)]


class STACKFRAME64(ctypes.Structure):
    _fields_ = [
        ("AddrPC", ADDRESS64),
        ("AddrReturn", ADDRESS64),
        ("AddrFrame", ADDRESS64),
        ("AddrStack", ADDRESS64),
        ("AddrBStore", ADDRESS64),
        ("FuncTableEntry", ctypes.c_void_p),
        ("Params", ctypes.c_uint64 * 4),
        ("Far", wt.BOOL),
        ("Virtual", wt.BOOL),
        ("Reserved", ctypes.c_uint64 * 3),
        ("KdHelp", KDHELP64),
    ]


class SYMBOL_INFO(ctypes.Structure):
    _fields_ = [
        ("SizeOfStruct", wt.ULONG),
        ("TypeIndex", wt.ULONG),
        ("Reserved", ctypes.c_uint64 * 2),
        ("Index", wt.ULONG),
        ("Size", wt.ULONG),
        ("ModBase", ctypes.c_uint64),
        ("Flags", wt.ULONG),
        ("Value", ctypes.c_uint64),
        ("Address", ctypes.c_uint64),
        ("Register", wt.ULONG),
        ("Scope", wt.ULONG),
        ("Tag", wt.ULONG),
        ("NameLen", wt.ULONG),
        ("MaxNameLen", wt.ULONG),
        ("Name", ctypes.c_char * 1024),
    ]


class IMAGEHLP_MODULE64(ctypes.Structure):
    _fields_ = [
        ("SizeOfStruct", wt.DWORD),
        ("BaseOfImage", ctypes.c_uint64),
        ("ImageSize", wt.DWORD),
        ("TimeDateStamp", wt.DWORD),
        ("CheckSum", wt.DWORD),
        ("NumSyms", wt.DWORD),
        ("SymType", ctypes.c_int),
        ("ModuleName", ctypes.c_char * 32),
        ("ImageName", ctypes.c_char * 256),
        ("LoadedImageName", ctypes.c_char * 256),
        ("rest", ctypes.c_byte * 4096),
    ]


# x64 CONTEXT: 1232 bytes, 16-byte aligned. Offsets from winnt.h.
CONTEXT_SIZE = 1232
OFF_FLAGS, OFF_RSP, OFF_RBP, OFF_RIP = 0x30, 0x98, 0xA0, 0xF8

k32.OpenProcess.restype = wt.HANDLE
k32.OpenThread.restype = wt.HANDLE
k32.CreateToolhelp32Snapshot.restype = wt.HANDLE
dbg.SymFunctionTableAccess64.restype = ctypes.c_void_p
dbg.SymFunctionTableAccess64.argtypes = [wt.HANDLE, ctypes.c_uint64]
dbg.SymGetModuleBase64.restype = ctypes.c_uint64
dbg.SymGetModuleBase64.argtypes = [wt.HANDLE, ctypes.c_uint64]
FTA = ctypes.WINFUNCTYPE(ctypes.c_void_p, wt.HANDLE, ctypes.c_uint64)(("SymFunctionTableAccess64", dbg))
GMB = ctypes.WINFUNCTYPE(ctypes.c_uint64, wt.HANDLE, ctypes.c_uint64)(("SymGetModuleBase64", dbg))
dbg.StackWalk64.argtypes = [
    wt.DWORD, wt.HANDLE, wt.HANDLE, ctypes.POINTER(STACKFRAME64), ctypes.c_void_p,
    ctypes.c_void_p, ctypes.c_void_p, ctypes.c_void_p, ctypes.c_void_p,
]


def aligned_context():
    raw = ctypes.create_string_buffer(CONTEXT_SIZE + 16)
    addr = (ctypes.addressof(raw) + 15) & ~15
    return raw, addr


def name_of(proc, pc):
    si = SYMBOL_INFO()
    si.SizeOfStruct = ctypes.sizeof(SYMBOL_INFO) - 1024 + 1
    si.MaxNameLen = 1000
    disp = ctypes.c_uint64()
    if dbg.SymFromAddr(proc, ctypes.c_uint64(pc), ctypes.byref(disp), ctypes.byref(si)):
        return f"{si.Name.decode(errors='replace')}+{disp.value:#x}"
    mod = IMAGEHLP_MODULE64()
    mod.SizeOfStruct = ctypes.sizeof(IMAGEHLP_MODULE64) - 4096 + 1024  # accept any of the struct's versions
    mod.SizeOfStruct = 0x690
    if dbg.SymGetModuleInfo64(proc, ctypes.c_uint64(pc), ctypes.byref(mod)):
        return f"{mod.ModuleName.decode(errors='replace')}+{pc - mod.BaseOfImage:#x}"
    return f"{pc:#x}"


def walk(proc, thread, max_frames):
    raw, ctx = aligned_context()
    ctypes.c_uint32.from_address(ctx + OFF_FLAGS).value = CONTEXT_FULL
    if k32.SuspendThread(thread) == 0xFFFFFFFF:
        return [f"(cannot suspend: {ctypes.get_last_error()})"]
    try:
        if not k32.GetThreadContext(thread, ctypes.c_void_p(ctx)):
            return [f"(no context: {ctypes.get_last_error()})"]
        sf = STACKFRAME64()
        sf.AddrPC.Offset = ctypes.c_uint64.from_address(ctx + OFF_RIP).value
        sf.AddrFrame.Offset = ctypes.c_uint64.from_address(ctx + OFF_RBP).value
        sf.AddrStack.Offset = ctypes.c_uint64.from_address(ctx + OFF_RSP).value
        sf.AddrPC.Mode = sf.AddrFrame.Mode = sf.AddrStack.Mode = AddrModeFlat
        pcs = []
        while len(pcs) < max_frames:
            ok = dbg.StackWalk64(IMAGE_FILE_MACHINE_AMD64, proc, thread, ctypes.byref(sf), ctypes.c_void_p(ctx),
                                 None, ctypes.cast(FTA, ctypes.c_void_p), ctypes.cast(GMB, ctypes.c_void_p), None)
            if not ok or sf.AddrPC.Offset == 0:
                break
            pcs.append(sf.AddrPC.Offset)
    finally:
        k32.ResumeThread(thread)
    return [name_of(proc, pc) for pc in pcs]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("pid", type=int)
    ap.add_argument("--frames", type=int, default=40)
    a = ap.parse_args()
    proc = k32.OpenProcess(PROCESS_ALL, False, a.pid)
    if not proc:
        sys.exit(f"cannot open process {a.pid}: {ctypes.get_last_error()}")
    dbg.SymSetOptions(0x2 | 0x4 | 0x200)  # undecorated names, deferred loads, no prompts
    # Search next to the exe for its PDB (factorio.pdb ships there), then the default places.
    exe = ctypes.create_unicode_buffer(1024)
    size = wt.DWORD(1024)
    k32.QueryFullProcessImageNameW(proc, 0, exe, ctypes.byref(size))
    search = exe.value.rsplit("\\", 1)[0].encode()
    if not dbg.SymInitialize(proc, search, True):
        sys.exit(f"SymInitialize failed: {ctypes.get_last_error()}")
    snap = k32.CreateToolhelp32Snapshot(TH32CS_SNAPTHREAD, 0)
    te = THREADENTRY32()
    te.dwSize = ctypes.sizeof(THREADENTRY32)
    tids = []
    ok = k32.Thread32First(snap, ctypes.byref(te))
    while ok:
        if te.th32OwnerProcessID == a.pid:
            tids.append(te.th32ThreadID)
        ok = k32.Thread32Next(snap, ctypes.byref(te))
    k32.CloseHandle(snap)
    for tid in tids:
        th = k32.OpenThread(THREAD_ACCESS, False, tid)
        if not th:
            print(f"== thread {tid}: cannot open ({ctypes.get_last_error()})")
            continue
        frames = walk(proc, th, a.frames)
        k32.CloseHandle(th)
        print(f"== thread {tid}")
        for f in frames:
            print(f"  {f}")
    dbg.SymCleanup(proc)


if __name__ == "__main__":
    main()
