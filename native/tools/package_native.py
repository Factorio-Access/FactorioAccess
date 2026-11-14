"""Package the native build for a release: fa-native.zip (the three DLLs that go next to factorio.exe, and version.txt)
and fa_native.pdb beside it, for crash triage. The installer downloads fa-native.zip together with the mod zip of
the same release; nothing here ever goes into the mod zip (tools/package_mod.py).

    python native/tools/package_native.py [--build native/build/ninja] [--out dist]
    python native/tools/package_native.py --mac [--build native/build/mac] [--out dist]

--mac makes fa-native-macos.zip instead: the two libraries, version.txt and the launcher (tools/mac/launcher:
launch.sh and FactorioAccess.app), which the installer unpacks into ~/Library/Application Support/FactorioAccess,
and fa_native-macos.dSYM.zip beside it. Run on a Mac (dsymutil).
"""

import argparse
import shutil
import subprocess
import zipfile
from pathlib import Path

NATIVE = Path(__file__).resolve().parent.parent
FILES = ["version.dll", "fa_native.dll", "prism.dll", "version.txt"]
MAC_FILES = ["libfa_native.dylib", "libprism.dylib", "version.txt"]
MAC_LAUNCHER = NATIVE / "tools" / "mac" / "launcher"


def add(z, path, name, executable=False):
    info = zipfile.ZipInfo.from_file(path, name)
    info.compress_type = zipfile.ZIP_DEFLATED
    info.external_attr = (0o100755 if executable else 0o100644) << 16  # unzip keeps the execute bits
    z.writestr(info, path.read_bytes())


def package_mac(build, out):
    missing = [f for f in MAC_FILES if not (build / f).is_file()]
    if missing:
        raise SystemExit(f"not built: {missing} in {build}")
    version = (build / "version.txt").read_text(encoding="utf-8").strip()
    zpath = out / "fa-native-macos.zip"
    with zipfile.ZipFile(zpath, "w") as z:
        for f in MAC_FILES:
            add(z, build / f, f, executable=f.endswith(".dylib"))
        for f in sorted(MAC_LAUNCHER.rglob("*")):
            if f.is_file():
                rel = f.relative_to(MAC_LAUNCHER).as_posix()
                add(z, f, rel, executable=rel == "launch.sh" or "/MacOS/" in rel)
    dsym = out / "libfa_native.dylib.dSYM"
    shutil.rmtree(dsym, ignore_errors=True)
    subprocess.run(["dsymutil", str(build / "libfa_native.dylib"), "-o", str(dsym)], check=True)
    shutil.make_archive(str(out / "fa_native-macos.dSYM"), "zip", out, dsym.name)
    shutil.rmtree(dsym)
    print(f"{zpath} ({version})")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--mac", action="store_true", help="package the macOS build")
    ap.add_argument("--build", type=Path)
    ap.add_argument("--out", type=Path, default=Path("dist"))
    a = ap.parse_args()
    a.out.mkdir(parents=True, exist_ok=True)
    if a.mac:
        package_mac(a.build or NATIVE / "build" / "mac", a.out)
        return
    a.build = a.build or NATIVE / "build" / "ninja"
    missing = [f for f in FILES if not (a.build / f).is_file()]
    if missing:
        raise SystemExit(f"not built: {missing} in {a.build}")
    version = (a.build / "version.txt").read_text(encoding="utf-8").strip()
    out = a.out / "fa-native.zip"
    with zipfile.ZipFile(out, "w", compression=zipfile.ZIP_DEFLATED) as z:
        for f in FILES:
            z.write(a.build / f, f)
    shutil.copyfile(a.build / "fa_native.pdb", a.out / "fa_native.pdb")
    print(f"{out} ({version})")


if __name__ == "__main__":
    main()
