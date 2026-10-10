"""Dev-loop client for the native code. Stdlib only: `python native/tools/fadev.py <command>`.

The game runs visible but never focused, muted unless --speak, with the DLL injected before it initialises.
It never touches the real desktop's focus or input.

  launch [--speak] [--nobuild] [-- game args]   build, start the game with the DLL, wait for /health
  reload [--nobuild]                             eject the DLL, rebuild, inject again (game keeps running)
  status                                         is the tracked game alive, and does the dev server answer
  kill                                           terminate the tracked game (only if it is provably ours)
  shot [out.png] [--width N]                     screenshot of the game window (works unfocused)
  health | log [--since N] | speech [--since N] [--wait S]
  say TEXT | mute on|off | get /route?query

Process identity: the launch records pid + creation time + image path in native/build/fadev_state.json.
Every command that acts on the process re-checks all three, so a pid Windows reused for another process
is never touched.
"""

import argparse
import ctypes
import ctypes.wintypes as wt
import json
import os
import struct
import subprocess
import sys
import time
import urllib.parse
import urllib.request
import zlib

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

NATIVE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MOD = os.path.dirname(NATIVE)
FACTORIO_EXE = os.path.normpath(os.path.join(MOD, "..", "..", "bin", "x64", "factorio.exe"))
BUILD = os.path.join(NATIVE, "build", "ninja")
DLL = os.path.join(BUILD, "fa_native.dll")
INJECT = os.path.join(BUILD, "fa_inject.exe")
STATE = os.path.join(NATIVE, "build", "fadev_state.json")
NATIVE_LOG = os.path.join(os.environ.get("LOCALAPPDATA", "."), "FactorioAccess", "native.log")
PORT = int(os.environ.get("FA_PORT", "8792"))

k32 = ctypes.WinDLL("kernel32", use_last_error=True)
u32 = ctypes.WinDLL("user32", use_last_error=True)
g32 = ctypes.WinDLL("gdi32", use_last_error=True)
k32.OpenProcess.restype = wt.HANDLE
k32.OpenProcess.argtypes = [wt.DWORD, wt.BOOL, wt.DWORD]

PROCESS_TERMINATE = 0x0001
PROCESS_QUERY_LIMITED_INFORMATION = 0x1000
SYNCHRONIZE = 0x00100000
STILL_ACTIVE = 259


# ---------------------------------------------------------------- process identity


def _creation_and_image(pid):
    """(creation FILETIME as int, image path) of a live pid, or None."""
    h = k32.OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, False, pid)
    if not h:
        return None
    try:
        code = wt.DWORD()
        if not k32.GetExitCodeProcess(h, ctypes.byref(code)) or code.value != STILL_ACTIVE:
            return None
        c, e, kt, ut = wt.FILETIME(), wt.FILETIME(), wt.FILETIME(), wt.FILETIME()
        if not k32.GetProcessTimes(h, ctypes.byref(c), ctypes.byref(e), ctypes.byref(kt), ctypes.byref(ut)):
            return None
        buf = ctypes.create_unicode_buffer(1024)
        size = wt.DWORD(len(buf))
        if not k32.QueryFullProcessImageNameW(h, 0, buf, ctypes.byref(size)):
            return None
        return (c.dwHighDateTime << 32) | c.dwLowDateTime, buf.value
    finally:
        k32.CloseHandle(h)


def _same_path(a, b):
    return os.path.normcase(os.path.abspath(a)) == os.path.normcase(os.path.abspath(b))


def tracked():
    """The tracked game's pid if the recorded process is still exactly that process, else None."""
    try:
        with open(STATE) as f:
            st = json.load(f)
    except (OSError, ValueError):
        return None
    info = _creation_and_image(st["pid"])
    if not info or info[0] != st["created"] or not _same_path(info[1], st["image"]):
        return None
    return st["pid"]


def record(pid):
    info = _creation_and_image(pid)
    if not info:
        sys.exit(f"pid {pid} died right after launch; see {NATIVE_LOG}")
    os.makedirs(os.path.dirname(STATE), exist_ok=True)
    with open(STATE, "w") as f:
        json.dump({"pid": pid, "created": info[0], "image": info[1]}, f)


def factorio_pids_of_this_install():
    """Every running factorio.exe whose image is this install's exe (ours or the developer's own session)."""
    out = subprocess.run(["tasklist", "/FI", "IMAGENAME eq factorio.exe", "/FO", "CSV", "/NH"], capture_output=True, text=True).stdout
    pids = []
    for line in out.splitlines():
        if line.startswith('"factorio.exe"'):
            pid = int(line.split('","')[1])
            info = _creation_and_image(pid)
            if info and _same_path(info[1], FACTORIO_EXE):
                pids.append(pid)
    return pids


def terminate(pid):
    """Terminate pid only after re-verifying it is the tracked process, through one handle (no reuse window)."""
    with open(STATE) as f:
        st = json.load(f)
    if st["pid"] != pid:
        sys.exit("refusing: not the tracked pid")
    h = k32.OpenProcess(PROCESS_TERMINATE | PROCESS_QUERY_LIMITED_INFORMATION | SYNCHRONIZE, False, pid)
    if not h:
        return
    try:
        c, e, kt, ut = wt.FILETIME(), wt.FILETIME(), wt.FILETIME(), wt.FILETIME()
        k32.GetProcessTimes(h, ctypes.byref(c), ctypes.byref(e), ctypes.byref(kt), ctypes.byref(ut))
        if (c.dwHighDateTime << 32) | c.dwLowDateTime != st["created"]:
            sys.exit("refusing: the pid now belongs to a different process")
        k32.TerminateProcess(h, 1)
        k32.WaitForSingleObject(h, 10000)
    finally:
        k32.CloseHandle(h)


# ---------------------------------------------------------------- dev server


def get(path, timeout=15, quiet=False):
    try:
        with urllib.request.urlopen(f"http://127.0.0.1:{PORT}{path}", timeout=timeout) as r:
            return r.read().decode("utf-8", errors="replace")
    except urllib.error.HTTPError as e:
        return e.read().decode("utf-8", errors="replace")
    except OSError as e:
        if quiet:
            return None
        sys.exit(f"dev server unreachable ({e}); run `fadev.py status`")


def q(**kw):
    return "?" + urllib.parse.urlencode({k: v for k, v in kw.items() if v is not None and v is not False})


# ---------------------------------------------------------------- commands


def build():
    r = subprocess.call(["cmd", "/c", os.path.join(NATIVE, "tools", "build.cmd")])
    if r != 0:
        sys.exit("build failed")


def wait_health(pid, seconds=60):
    deadline = time.time() + seconds
    while time.time() < deadline:
        h = get("/health", timeout=2, quiet=True)
        if h:
            print(h, end="")
            return True
        if tracked() != pid:
            print(f"the game exited during startup; see {NATIVE_LOG} and factorio-current.log")
            return False
        time.sleep(0.5)
    print("timed out waiting for /health")
    return False


def cmd_launch(a):
    if tracked():
        sys.exit("the tracked game is still running; `kill` it first (or `reload` to swap the DLL)")
    others = factorio_pids_of_this_install()
    if others:
        sys.exit(f"factorio from this install is already running (pid {others}); it holds the write-data lock")
    if not a.nobuild:
        build()
    env = dict(os.environ, FA_NOFOCUS="1", FA_PORT=str(PORT))
    if a.speak:
        env.pop("FA_MUTE", None)
    else:
        env["FA_MUTE"] = "1"
    out = subprocess.run([INJECT, "--launch", FACTORIO_EXE, DLL] + a.game_args, capture_output=True, text=True, env=env)
    print(out.stdout, end="")
    pid = next((int(l.split()[1]) for l in out.stdout.splitlines() if l.startswith("pid ")), None)
    if out.returncode != 0 or pid is None:
        sys.exit("launch failed")
    record(pid)
    if not wait_health(pid):
        sys.exit(1)


def cmd_reload(a):
    pid = tracked()
    if not pid:
        sys.exit("no tracked game running")
    subprocess.call([INJECT, "--eject", str(pid), DLL])
    if not a.nobuild:
        build()
    if subprocess.call([INJECT, "--inject", str(pid), DLL]) != 0:
        sys.exit("inject failed")
    wait_health(pid, 15)


def cmd_status(a):
    pid = tracked()
    if not pid:
        others = factorio_pids_of_this_install()
        print("status: not running" + (f" (untracked factorio from this install: {others})" if others else ""))
        return
    h = get("/health", timeout=3, quiet=True)
    print(f"pid {pid}")
    print("status:", "running, " + h.strip() if h else "alive but the dev server does not answer (loading, hung, or a crash dialog)")


def cmd_kill(a):
    pid = tracked()
    if not pid:
        print("no tracked game running")
        return
    terminate(pid)
    print(f"killed {pid}")


def find_window(pid):
    found = []
    proc = ctypes.WINFUNCTYPE(wt.BOOL, wt.HWND, wt.LPARAM)

    def cb(h, _):
        p = wt.DWORD()
        u32.GetWindowThreadProcessId(h, ctypes.byref(p))
        if p.value == pid and u32.IsWindowVisible(h) and u32.GetWindowTextLengthW(h) > 0:
            found.append(h)
        return True

    u32.EnumWindows(proc(cb), 0)
    return found[0] if found else None


def png_bytes(w, h, rgb_rows):
    def chunk(tag, data):
        return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)

    raw = b"".join(b"\x00" + row for row in rgb_rows)
    return b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 2, 0, 0, 0)) + chunk(b"IDAT", zlib.compress(raw, 6)) + chunk(b"IEND", b"")


def cmd_shot(a):
    pid = tracked()
    if not pid:
        sys.exit("no tracked game running")
    hwnd = find_window(pid)
    if not hwnd:
        sys.exit("the game has no visible window yet")
    r = wt.RECT()
    u32.GetClientRect(hwnd, ctypes.byref(r))
    w, h = r.right - r.left, r.bottom - r.top
    hdc = u32.GetDC(hwnd)
    mdc = g32.CreateCompatibleDC(hdc)
    bmp = g32.CreateCompatibleBitmap(hdc, w, h)
    g32.SelectObject(mdc, bmp)
    PW_CLIENTONLY, PW_RENDERFULLCONTENT = 1, 2
    ok = u32.PrintWindow(hwnd, mdc, PW_CLIENTONLY | PW_RENDERFULLCONTENT)

    class BMI(ctypes.Structure):
        _fields_ = [("biSize", wt.DWORD), ("biWidth", wt.LONG), ("biHeight", wt.LONG), ("biPlanes", wt.WORD), ("biBitCount", wt.WORD),
                    ("biCompression", wt.DWORD), ("biSizeImage", wt.DWORD), ("biXPelsPerMeter", wt.LONG), ("biYPelsPerMeter", wt.LONG),
                    ("biClrUsed", wt.DWORD), ("biClrImportant", wt.DWORD)]

    bi = BMI(biSize=ctypes.sizeof(BMI), biWidth=w, biHeight=-h, biPlanes=1, biBitCount=24)
    stride = (w * 3 + 3) & ~3
    data = ctypes.create_string_buffer(stride * h)
    g32.GetDIBits(mdc, bmp, 0, h, data, ctypes.byref(bi), 0)
    g32.DeleteObject(bmp)
    g32.DeleteDC(mdc)
    u32.ReleaseDC(hwnd, hdc)
    if not ok:
        sys.exit("PrintWindow failed")
    step = max(1, -(-w // a.width)) if a.width else 1  # integer downscale by nearest-pixel sampling
    rows = []
    for y in range(0, h, step):
        line = data.raw[y * stride:y * stride + w * 3]
        bgr = line[::1] if step == 1 else b"".join(line[x * 3:x * 3 + 3] for x in range(0, w, step))
        rgb = bytearray(bgr)
        rgb[0::3], rgb[2::3] = bgr[2::3], bgr[0::3]
        rows.append(bytes(rgb))
    out_w = len(rows[0]) // 3
    path = a.out or os.path.join(NATIVE, "build", "shot.png")
    with open(path, "wb") as f:
        f.write(png_bytes(out_w, len(rows), rows))
    print(path)


def cmd_speech(a):
    deadline = time.time() + (a.wait or 0)
    while True:
        out = get(f"/speech?since={a.since}")
        if out.count("\n") > 1 or time.time() >= deadline:
            print(out, end="")
            return
        time.sleep(0.3)


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = p.add_subparsers(dest="cmd", required=True)
    s = sub.add_parser("launch")
    s.add_argument("--speak", action="store_true")
    s.add_argument("--nobuild", action="store_true")
    s.add_argument("game_args", nargs="*")
    s.set_defaults(f=cmd_launch)
    s = sub.add_parser("reload")
    s.add_argument("--nobuild", action="store_true")
    s.set_defaults(f=cmd_reload)
    sub.add_parser("status").set_defaults(f=cmd_status)
    sub.add_parser("kill").set_defaults(f=cmd_kill)
    s = sub.add_parser("shot")
    s.add_argument("out", nargs="?")
    s.add_argument("--width", type=int, default=1600)
    s.set_defaults(f=cmd_shot)
    sub.add_parser("health").set_defaults(f=lambda a: print(get("/health"), end=""))
    s = sub.add_parser("log")
    s.add_argument("--since", type=int, default=0)
    s.set_defaults(f=lambda a: print(get(f"/log?since={a.since}"), end=""))
    s = sub.add_parser("speech")
    s.add_argument("--since", type=int, default=0)
    s.add_argument("--wait", type=float, default=0)
    s.set_defaults(f=cmd_speech)
    s = sub.add_parser("say")
    s.add_argument("text")
    s.set_defaults(f=lambda a: print(get("/say" + q(text=a.text)), end=""))
    s = sub.add_parser("mute")
    s.add_argument("on")
    s.set_defaults(f=lambda a: print(get("/mute" + q(on=a.on)), end=""))
    s = sub.add_parser("get")
    s.add_argument("path")
    s.set_defaults(f=lambda a: print(get(a.path), end=""))
    a = p.parse_args()
    a.f(a)


if __name__ == "__main__":
    main()
