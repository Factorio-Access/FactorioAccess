"""Dev-loop client for the native code. Stdlib only: `python native/tools/fadev.py <command>`.

The game runs visible but never focused, muted unless --speak, with the DLL injected before it initialises.
It never touches the real desktop's focus or input.

  launch [--speak] [--nobuild] [-- game args]   build, start the game with the DLL, wait for /health
  reload [--nobuild]                             eject the DLL, rebuild, inject again (game keeps running)
  status                                         is the tracked game alive, and does the dev server answer
  install [--nobuild] | uninstall                put version.dll + fa_native.dll + prism.dll next to factorio.exe
                                                 (then just run the game; launch keeps using its own injected build)
  kill [--hard]                                  close the tracked game (WM_CLOSE, then terminate; only if provably ours)
  shot [out.png] [--width N]                     screenshot of the game window (works unfocused)
  health | log [--since N] | speech [--since N] [--wait S]
  say TEXT | mute on|off | key NAME [--shift --ctrl --alt] | keys TEXT
  tree [--all]                                   the game's widget tree
  get route?query                                any dev-server route (no leading slash: Git Bash rewrites /paths)
  lua CODE|- [--file F] [--timeout S]            run Lua in the mod's state in the loaded game (over Lua UDP), print the result
                                                 (chunks get localise, profile, profile_calls/profile_report: see scripts/dev-udp.lua)
  wait [--ticks N] [--until EXPR] [--timeout S]  wait for a loaded world, then N more ticks or until EXPR is truthy
  fixture [NAME [key=value ...]]                 run native/tools/fixtures/NAME.lua with those args; no NAME lists them

launch with --load-game (or another argument that loads a world) waits for the world too, so the next command can
talk to it.

Process identity: the launch records pid + creation time + image path in native/build/fadev_state.json.
Every command that acts on the process re-checks all three, so a pid Windows reused for another process
is never touched.
"""

import argparse
import ctypes
import ctypes.wintypes as wt
import json
import shutil
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
NATIVE_LOG = os.path.join(os.environ.get("LOCALAPPDATA", "."), "FactorioAccess", "native-dev.log")
PORT = int(os.environ.get("FA_PORT", "8792"))
# The game listens here for Lua to run (scripts/dev-udp.lua); launch passes it as --enable-lua-udp.
UDP_PORT = int(os.environ.get("FA_UDP_PORT", "8793"))

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


# Game arguments that load a world: launch then waits until the mod answers.
WORLD_ARGS = {"--load-game", "--load-scenario", "--create", "--start-server"}


def cmd_launch(a):
    if tracked():
        sys.exit("the tracked game is still running; `kill` it first (or `reload` to swap the DLL)")
    # A game with its own --config (and so its own write-data) doesn't contend for the install's lock.
    others = [] if "--config" in a.game_args else factorio_pids_of_this_install()
    if others:
        sys.exit(f"factorio from this install is already running (pid {others}); it holds the write-data lock")
    if not a.nobuild:
        build()
    # FA_NO_PROXY: an installed version.dll stays idle; the dev loop injects its own build instead.
    env = dict(os.environ, FA_PORT=str(PORT), FA_NO_PROXY="1")
    # --focus: let the game take focus like a normal run (it may move the mouse); for bugs that need it.
    if not a.focus:
        env["FA_NOFOCUS"] = "1"
    if a.speak:
        env.pop("FA_MUTE", None)
    else:
        env["FA_MUTE"] = "1"
    game_args = ["--enable-lua-udp", str(UDP_PORT)] + a.game_args
    out = subprocess.run([INJECT, "--launch", FACTORIO_EXE, DLL] + game_args, capture_output=True, text=True, env=env)
    print(out.stdout, end="")
    pid = next((int(l.split()[1]) for l in out.stdout.splitlines() if l.startswith("pid ")), None)
    if out.returncode != 0 or pid is None:
        sys.exit("launch failed")
    record(pid)
    if not wait_health(pid):
        sys.exit(1)
    if any(arg in WORLD_ARGS for arg in a.game_args):
        tick = wait_world(180)
        if tick is None:
            sys.exit("the world did not answer over UDP in 180s")
        print(f"world loaded, tick {tick}")


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
    """Close the window first so the game exits cleanly (it records state on exit, e.g. that the changelog was
    seen); terminate only if it is still alive after the grace period, or at once with --hard."""
    pid = tracked()
    if not pid:
        print("no tracked game running")
        return
    if not a.hard:
        hwnd = find_window(pid)
        if hwnd:
            WM_CLOSE = 0x0010
            u32.PostMessageW(hwnd, WM_CLOSE, 0, 0)
            deadline = time.time() + 15
            while time.time() < deadline and tracked() == pid:
                time.sleep(0.25)
            if tracked() != pid:
                print(f"closed {pid}")
                return
            print("still running after WM_CLOSE; terminating")
    terminate(pid)
    print(f"killed {pid}")


GAME_BIN = os.path.dirname(FACTORIO_EXE)
INSTALLED = ["version.dll", "fa_native.dll", "prism.dll"]


def cmd_install(a):
    """Put the proxy and the native code next to factorio.exe: launching the game normally then loads them."""
    if factorio_pids_of_this_install():
        sys.exit("close factorio first (its DLLs are in use)")
    if not a.nobuild:
        build()
    for name in INSTALLED:
        shutil.copy2(os.path.join(BUILD, name), os.path.join(GAME_BIN, name))
        print("installed", os.path.join(GAME_BIN, name))


def cmd_uninstall(a):
    if factorio_pids_of_this_install():
        sys.exit("close factorio first (its DLLs are in use)")
    for name in INSTALLED:
        path = os.path.join(GAME_BIN, name)
        if os.path.exists(path):
            os.remove(path)
            print("removed", path)


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


def lua_eval(code, timeout):
    """(ok, body) for a Lua chunk run in the mod's state, or None when nothing answered in time."""
    # The mod runs packets that start with this (scripts/dev-udp.lua) and replies to our port. It reads UDP once a tick,
    # so a paused game or one still in the menus answers late or not at all.
    import socket

    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as sock:
        sock.bind(("127.0.0.1", 0))
        sock.settimeout(timeout)
        sock.sendto(("fa-eval\n" + code).encode("utf-8"), ("127.0.0.1", UDP_PORT))
        try:
            reply, _ = sock.recvfrom(65536)
        # Windows reports an unreachable port (no world loaded yet) as a reset of the socket
        except (socket.timeout, ConnectionResetError):
            return None
    status, _, body = reply.decode("utf-8", "replace").partition("\n")
    return status == "ok", body


def run_lua(code, timeout):
    result = lua_eval(code, timeout)
    if result is None:
        sys.exit(f"no reply in {timeout}s (is a game loaded and unpaused, launched by fadev with --enable-lua-udp?)")
    ok, body = result
    print(body)
    if not ok:
        sys.exit(1)


def cmd_lua(a):
    if a.file:
        with open(a.file, encoding="utf-8") as f:
            code = f.read()
    elif a.code == "-":
        code = sys.stdin.read()
    elif a.code is not None:
        code = a.code
    else:
        sys.exit("give CODE, - or --file")
    run_lua(code, a.timeout)


def wait_world(seconds):
    """Until the mod answers over UDP, which it does once a world is loaded and running. The tick, or None."""
    deadline = time.time() + seconds
    while time.time() < deadline:
        result = lua_eval("return game.tick", 1)
        if result and result[0]:
            return int(result[1])
        if not tracked():
            return None
        time.sleep(0.25)
    return None


def current_tick():
    result = lua_eval("return game.tick", 2)
    return int(result[1]) if result and result[0] else None


def cmd_wait(a):
    deadline = time.time() + a.timeout
    tick = wait_world(a.timeout)
    if tick is None:
        sys.exit(f"no world answered in {a.timeout}s")
    target = tick + a.ticks
    while tick < target:
        if time.time() > deadline:
            sys.exit(f"timed out at tick {tick}, waiting for {target} (paused?)")
        time.sleep(min(0.5, (target - tick) / 60))
        tick = current_tick() or tick
    while a.until:
        result = lua_eval(a.until, 2)
        if result:
            ok, body = result
            if not ok:
                sys.exit("error: " + body)
            if body.strip() not in ("", "nil", "false"):
                break
        if time.time() > deadline:
            sys.exit(f"timed out waiting for: {a.until}")
        time.sleep(0.1)
    print(f"tick {current_tick()}")


FIXTURES = os.path.join(NATIVE, "tools", "fixtures")


def lua_value(text):
    """A command-line value as Lua: numbers and booleans as they are, anything else a string."""
    if text in ("true", "false"):
        return text
    try:
        float(text)
        return text
    except ValueError:
        return json.dumps(text)


def cmd_fixture(a):
    if not a.name:
        for name in sorted(os.listdir(FIXTURES)):
            if name.endswith(".lua"):
                with open(os.path.join(FIXTURES, name), encoding="utf-8") as f:
                    first = f.readline().strip().lstrip("-").strip()
                print(f"{name[:-4]}: {first}")
        return
    path = os.path.join(FIXTURES, a.name + ".lua")
    if not os.path.exists(path):
        sys.exit(f"no fixture {a.name}; `fixture` lists them")
    pairs = []
    for arg in a.args:
        key, sep, value = arg.partition("=")
        if not sep or not key.isidentifier():
            sys.exit(f"arguments are key=value, not {arg}")
        pairs.append(f"{key} = {lua_value(value)}")
    with open(path, encoding="utf-8") as f:
        code = "local args = { " + ", ".join(pairs) + " }\n" + f.read()
    run_lua(code, a.timeout)


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = p.add_subparsers(dest="cmd", required=True)
    s = sub.add_parser("launch")
    s.add_argument("--speak", action="store_true")
    s.add_argument("--nobuild", action="store_true")
    s.add_argument("--focus", action="store_true")
    s.add_argument("game_args", nargs="*")
    s.set_defaults(f=cmd_launch)
    s = sub.add_parser("reload")
    s.add_argument("--nobuild", action="store_true")
    s.set_defaults(f=cmd_reload)
    sub.add_parser("status").set_defaults(f=cmd_status)
    s = sub.add_parser("install")
    s.add_argument("--nobuild", action="store_true")
    s.set_defaults(f=cmd_install)
    sub.add_parser("uninstall").set_defaults(f=cmd_uninstall)
    s = sub.add_parser("kill")
    s.add_argument("--hard", action="store_true")
    s.set_defaults(f=cmd_kill)
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
    # Routes are given without the leading slash (`get ui/tree?all=1`): Git Bash rewrites /-paths into Windows paths.
    s = sub.add_parser("get")
    s.add_argument("path")
    s.set_defaults(f=lambda a: print(get("/" + a.path.lstrip("/")), end=""))
    s = sub.add_parser("key")
    s.add_argument("name")
    s.add_argument("--shift", action="store_true")
    s.add_argument("--ctrl", action="store_true")
    s.add_argument("--alt", action="store_true")
    s.set_defaults(f=lambda a: print(get("/key" + q(name=a.name, shift=a.shift and 1, ctrl=a.ctrl and 1, alt=a.alt and 1)), end=""))
    s = sub.add_parser("keys")
    s.add_argument("text")
    s.set_defaults(f=lambda a: print(get("/keys" + q(text=a.text)), end=""))
    s = sub.add_parser("lua", help="run Lua in the mod's state in the loaded game and print what it returns")
    s.add_argument("code", nargs="?", help="a Lua chunk or expression; - reads it from stdin")
    s.add_argument("--file", help="read the chunk from this file")
    s.add_argument("--timeout", type=float, default=5)
    s.set_defaults(f=cmd_lua)
    s = sub.add_parser("wait", help="wait for a loaded world, then for ticks to pass or a Lua expression to be truthy")
    s.add_argument("--ticks", type=int, default=0)
    s.add_argument("--until", help="a Lua expression, polled until it is neither nil nor false")
    s.add_argument("--timeout", type=float, default=120)
    s.set_defaults(f=cmd_wait)
    s = sub.add_parser("fixture", help="run a setup script from native/tools/fixtures")
    s.add_argument("name", nargs="?")
    s.add_argument("args", nargs="*", help="key=value, passed to the script as the table `args`")
    s.add_argument("--timeout", type=float, default=30)
    s.set_defaults(f=cmd_fixture)
    s = sub.add_parser("tree")
    s.add_argument("--all", action="store_true")
    s.set_defaults(f=lambda a: print(get("/ui/tree" + q(all=1 if a.all else None)), end=""))
    a = p.parse_args()
    a.f(a)


if __name__ == "__main__":
    main()
