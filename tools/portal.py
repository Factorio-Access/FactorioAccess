"""The Factorio mod portal upload, behind a gate that only a genuine version tag passes.

    python tools/portal.py gate                              -> exit 0 only for a release tag push (reads GITHUB_*)
    python tools/portal.py upload <zip> --sha256 <hex>       -> gate, re-verify the zip, then upload it
    python tools/portal.py upload <zip> --sha256 <hex> --dry-run   -> everything but the upload (never reads the key)

The gate passes only when ALL hold: the event is a push, the ref is exactly refs/tags/vX.Y.Z (digits only), the tag
equals "v" + info.json's version, and the zip about to be uploaded is FactorioAccess_<that version>.zip. `upload`
then re-runs the whitelist verification (tools/package_mod.py) on the zip and checks its sha256 against the one
the packaging job recorded, so the bytes that reach the portal are exactly the bytes that were verified.
The API key is read from FACTORIO_UPLOAD_API_KEY only after every check passed, and never in --dry-run.
"""

import argparse
import hashlib
import json
import os
import re
import sys
import urllib.request
import uuid
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import package_mod  # noqa: E402

TAG_REF = re.compile(r"refs/tags/v([0-9]+\.[0-9]+\.[0-9]+)")
INIT_UPLOAD_URL = "https://mods.factorio.com/api/v2/mods/releases/init_upload"


class Refused(Exception):
    pass


def gate(event: str, ref: str, info_version: str) -> str:
    """The version to publish, or Refused with the reason."""
    if event != "push":
        raise Refused(f"event is {event!r}, not a push")
    m = TAG_REF.fullmatch(ref)
    if not m:
        raise Refused(f"ref {ref!r} is not refs/tags/vX.Y.Z")
    if m[1] != info_version:
        raise Refused(f"tag v{m[1]} does not match info.json version {info_version}")
    return m[1]


def gate_from_env() -> str:
    info = json.loads((package_mod.ROOT / "info.json").read_text(encoding="utf-8"))
    return gate(os.environ.get("GITHUB_EVENT_NAME", ""), os.environ.get("GITHUB_REF", ""), info["version"])


def check_zip(zip_path: Path, version: str, sha256: str) -> None:
    expected = f"{package_mod.MOD_NAME}_{version}.zip"
    if zip_path.name != expected:
        raise Refused(f"zip is {zip_path.name}, expected {expected}")
    problems = package_mod.verify(zip_path)
    if problems:
        raise Refused("zip failed whitelist verification: " + "; ".join(problems[:20]))
    digest = hashlib.sha256(zip_path.read_bytes()).hexdigest()
    if not sha256 or digest != sha256.lower():
        raise Refused(f"zip sha256 {digest} does not match the packaged one {sha256!r}")


def _post_json(url: str, body: bytes, headers: dict) -> dict:
    req = urllib.request.Request(url, data=body, headers=headers, method="POST")
    with urllib.request.urlopen(req, timeout=120) as resp:
        return json.loads(resp.read())


def http_upload(zip_path: Path, api_key: str) -> None:
    """The real upload (mod portal API v2: init_upload, then the file to the returned URL)."""
    init = _post_json(
        INIT_UPLOAD_URL,
        f"mod={package_mod.MOD_NAME}".encode(),
        {"Authorization": f"Bearer {api_key}", "Content-Type": "application/x-www-form-urlencoded"},
    )
    if "upload_url" not in init:
        raise SystemExit(f"init_upload failed: {init}")
    boundary = uuid.uuid4().hex
    body = (
        f'--{boundary}\r\nContent-Disposition: form-data; name="file"; filename="{zip_path.name}"\r\n'
        f"Content-Type: application/zip\r\n\r\n"
    ).encode() + zip_path.read_bytes() + f"\r\n--{boundary}--\r\n".encode()
    result = _post_json(init["upload_url"], body, {"Content-Type": f"multipart/form-data; boundary={boundary}"})
    if not result.get("success"):
        raise SystemExit(f"upload failed: {result}")
    print(f"uploaded {zip_path.name} to the mod portal")


def upload(zip_path: Path, sha256: str, dry_run: bool, uploader=http_upload) -> str:
    version = gate_from_env()
    check_zip(zip_path, version, sha256)
    if dry_run:
        return f"DRY RUN: gate passed for v{version}; would upload {zip_path.name} (upload stubbed out)"
    key = os.environ.get("FACTORIO_UPLOAD_API_KEY", "")
    if not key:
        raise SystemExit("FACTORIO_UPLOAD_API_KEY is not set")
    uploader(zip_path, key)
    return f"uploaded v{version}"


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    sub.add_parser("gate")
    u = sub.add_parser("upload")
    u.add_argument("zip", type=Path)
    u.add_argument("--sha256", required=True)
    u.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()
    try:
        if args.cmd == "gate":
            print(f"gate passed: v{gate_from_env()} is a release tag matching info.json")
        else:
            print(upload(args.zip, args.sha256, args.dry_run))
    except Refused as e:
        print(f"REFUSED: {e}", file=sys.stderr)
        raise SystemExit(1)


if __name__ == "__main__":
    main()
