"""Package the native build for a release: fa-native.zip (the three DLLs that go next to factorio.exe, and version.txt)
and fa_native.pdb beside it, for crash triage. The installer downloads fa-native.zip together with the mod zip of
the same release; nothing here ever goes into the mod zip (tools/package_mod.py).

    python native/tools/package_native.py [--build native/build/ninja] [--out dist]
"""

import argparse
import shutil
import zipfile
from pathlib import Path

NATIVE = Path(__file__).resolve().parent.parent
FILES = ["version.dll", "fa_native.dll", "prism.dll", "version.txt"]


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--build", type=Path, default=NATIVE / "build" / "ninja")
    ap.add_argument("--out", type=Path, default=Path("dist"))
    a = ap.parse_args()
    a.out.mkdir(parents=True, exist_ok=True)
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
