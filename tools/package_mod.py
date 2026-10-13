"""Build and verify the mod zip that goes to the Factorio mod portal and into GitHub releases.

    python tools/package_mod.py build [--out dist]      -> dist/FactorioAccess_<version>.zip (prints the path)
    python tools/package_mod.py verify <zip>            -> exit 1 unless every entry is on the whitelist
    python tools/package_mod.py list                    -> the files a build would take, one per line

The zip is built by COPYING an explicit whitelist of tracked files (git ls-files), so anything not listed here is
left out by construction: native code, the installer, tooling, docs and tests never reach the portal. `verify` is a
second, independent check run on the finished zip (and again right before the portal upload): it opens the zip and
fails on any entry outside the whitelist, on any forbidden extension or path part, and on an info.json that does
not match the zip's name. Adding a runtime file or folder to the mod means adding it here.
"""

import argparse
import hashlib
import json
import subprocess
import sys
import zipfile
from pathlib import Path, PurePosixPath

ROOT = Path(__file__).resolve().parent.parent
MOD_NAME = "FactorioAccess"

# Top-level files the game loads (or shows on the portal / in the mod list).
WHITELIST_FILES = {
    "info.json",
    "changelog.txt",
    "thumbnail.png",
    "LICENSE",
    "control.lua",
    "data.lua",
    "data-updates.lua",
    "data-final-fixes.lua",
    "settings.lua",
    "syntrax.lua",
    "polyfill.lua",
    "math-helpers.lua",
    "serpent.lua",
}

# Folders taken recursively, each with the extensions allowed inside it. Subfolders listed in EXCLUDED_DIRS are
# skipped (offline unit tests that need luaunit; scripts/tests is the in-game test framework's and stays).
WHITELIST_DIRS = {
    "scripts": {".lua"},
    "syntrax": {".lua"},
    "ds": {".lua"},
    "railutils": {".lua"},
    "data": {".lua"},
    "locale": {".cfg", ".txt"},
    "audio": {".ogg", ".wav"},
    "Graphics": {".png"},
    "config_changes": {".ini"},
    "migrations": {".lua"},
}
EXCLUDED_DIRS = {"syntrax/tests", "ds/tests", "railutils/tests"}

# Never in the mod zip, whatever the whitelist says: native code and its build products, the installer, Python.
FORBIDDEN_EXTENSIONS = {
    ".dll", ".exe", ".pdb", ".lib", ".obj", ".o", ".a", ".exp", ".ilk",
    ".cpp", ".cc", ".cxx", ".c", ".h", ".hpp", ".hxx", ".inl", ".rs", ".toml", ".lock",
    ".py", ".pyc", ".cmd", ".bat", ".ps1", ".sh", ".zip", ".7z", ".rc", ".manifest",
}
FORBIDDEN_PARTS = {"native", "installer", "tools", ".github", ".git", ".tools", "scratchpad", "target", "build",
                   "__pycache__", "llm-docs", "devdocs", "docs", "helper-scripts", ".claude", ".vscode"}


def allowed(rel: str) -> bool:
    """Whether a path relative to the mod root (forward slashes) belongs in the zip."""
    p = PurePosixPath(rel)
    if rel in WHITELIST_FILES:
        return True
    if len(p.parts) < 2 or p.parts[0] not in WHITELIST_DIRS:
        return False
    if any(rel.startswith(d + "/") for d in EXCLUDED_DIRS):
        return False
    return p.suffix.lower() in WHITELIST_DIRS[p.parts[0]]


def forbidden(rel: str) -> str | None:
    """Why a path must never ship, or None."""
    p = PurePosixPath(rel)
    if p.suffix.lower() in FORBIDDEN_EXTENSIONS:
        return f"forbidden extension {p.suffix}"
    for part in p.parts:
        if part.lower() in FORBIDDEN_PARTS:
            return f"forbidden path part {part!r}"
    return None


def read_version() -> str:
    info = json.loads((ROOT / "info.json").read_text(encoding="utf-8"))
    if info.get("name") != MOD_NAME:
        raise SystemExit(f"info.json names {info.get('name')!r}, expected {MOD_NAME!r}")
    return info["version"]


def tracked_files() -> list[str]:
    out = subprocess.run(["git", "ls-files", "-z"], cwd=ROOT, check=True, capture_output=True).stdout
    return [f for f in out.decode("utf-8").split("\0") if f]


def selected_files() -> list[str]:
    files = sorted(f for f in tracked_files() if allowed(f))
    bad = [(f, forbidden(f)) for f in files if forbidden(f)]
    if bad:
        raise SystemExit("whitelist selected forbidden files: " + ", ".join(f"{f} ({why})" for f, why in bad))
    missing = sorted(WHITELIST_FILES - set(files))
    if missing:
        raise SystemExit(f"whitelisted top-level files are not tracked: {missing}")
    return files


def build(out_dir: Path) -> Path:
    version = read_version()
    top = f"{MOD_NAME}_{version}"
    out_dir.mkdir(parents=True, exist_ok=True)
    out = out_dir / f"{top}.zip"
    tmp = out.with_suffix(".zip.tmp")
    files = selected_files()
    with zipfile.ZipFile(tmp, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as z:
        for rel in files:
            data = (ROOT / rel).read_bytes()
            info = zipfile.ZipInfo(f"{top}/{rel}", date_time=(2020, 1, 1, 0, 0, 0))  # reproducible
            info.compress_type = zipfile.ZIP_DEFLATED
            info.external_attr = 0o644 << 16
            z.writestr(info, data)
    tmp.replace(out)
    print(f"{len(files)} files", file=sys.stderr)
    return out


def verify(zip_path: Path) -> list[str]:
    """Every problem with the zip; empty means it may ship."""
    problems = []
    name = zip_path.name
    if not (name.startswith(MOD_NAME + "_") and name.endswith(".zip")):
        return [f"zip name {name!r} is not {MOD_NAME}_<version>.zip"]
    top = name[: -len(".zip")]
    version = top[len(MOD_NAME) + 1 :]
    with zipfile.ZipFile(zip_path) as z:
        names = z.namelist()
        if not names:
            return ["the zip is empty"]
        for entry in names:
            if "\\" in entry:
                problems.append(f"{entry}: backslash in entry name")
                continue
            if entry.endswith("/"):
                rel = entry[len(top) + 1 :].rstrip("/")
                if not entry.startswith(top + "/"):
                    problems.append(f"{entry}: outside {top}/")
                elif rel and (why := forbidden(rel + "/x")):
                    problems.append(f"{entry}: {why}")
                continue
            if not entry.startswith(top + "/"):
                problems.append(f"{entry}: outside {top}/")
                continue
            rel = entry[len(top) + 1 :]
            if ".." in PurePosixPath(rel).parts or rel.startswith("/"):
                problems.append(f"{entry}: unsafe path")
            elif why := forbidden(rel):
                problems.append(f"{entry}: {why}")
            elif not allowed(rel):
                problems.append(f"{entry}: not on the whitelist")
        try:
            info = json.loads(z.read(f"{top}/info.json"))
            if info.get("name") != MOD_NAME or info.get("version") != version:
                problems.append(f"info.json says {info.get('name')} {info.get('version')}, the zip is {top}")
            if "package" in info:
                problems.append("info.json still has a package section (fmtk's ignore list is not used)")
        except KeyError:
            problems.append(f"{top}/info.json is missing")
        for required in ("control.lua", "data.lua", "settings.lua", "locale/en/controls.cfg"):
            if f"{top}/{required}" not in names:
                problems.append(f"{top}/{required} is missing")
    return problems


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    b = sub.add_parser("build")
    b.add_argument("--out", default="dist", type=Path)
    v = sub.add_parser("verify")
    v.add_argument("zip", type=Path)
    sub.add_parser("list")
    args = ap.parse_args()
    if args.cmd == "build":
        out = build(args.out if args.out.is_absolute() else ROOT / args.out)
        problems = verify(out)
        if problems:
            print("\n".join(problems), file=sys.stderr)
            raise SystemExit(f"the built zip failed verification ({len(problems)} problems)")
        print(out)
    elif args.cmd == "verify":
        problems = verify(args.zip)
        if problems:
            print("\n".join(problems), file=sys.stderr)
            raise SystemExit(f"REFUSED: {args.zip} has {len(problems)} entries that must not ship")
        with zipfile.ZipFile(args.zip) as z:
            count = len(z.namelist())
        digest = hashlib.sha256(args.zip.read_bytes()).hexdigest()
        print(f"OK: {args.zip.name}, {count} entries, all on the whitelist, sha256 {digest}")
    else:
        print("\n".join(selected_files()))


if __name__ == "__main__":
    main()
