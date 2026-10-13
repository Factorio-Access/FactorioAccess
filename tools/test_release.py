"""Tests for the mod zip whitelist and the portal gate: python -m unittest discover -s tools -p "test_*.py"

The upload is always a stub here: these tests prove which refs reach it, and never touch the network or the key.
"""

import hashlib
import json
import os
import tempfile
import unittest
import zipfile
from pathlib import Path
from unittest import mock

import package_mod
import portal

VERSION = json.loads((package_mod.ROOT / "info.json").read_text(encoding="utf-8"))["version"]


def env(event, ref):
    return mock.patch.dict(os.environ, {"GITHUB_EVENT_NAME": event, "GITHUB_REF": ref, "FACTORIO_UPLOAD_API_KEY": "fake"})


class Fixture(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.tmp = tempfile.TemporaryDirectory()
        cls.zip = package_mod.build(Path(cls.tmp.name))
        cls.sha = hashlib.sha256(cls.zip.read_bytes()).hexdigest()

    @classmethod
    def tearDownClass(cls):
        cls.tmp.cleanup()

    def tampered(self, extra: dict, name=None) -> Path:
        """A copy of the real zip with extra entries (name -> bytes)."""
        out = Path(self.tmp.name) / "bad" / (name or self.zip.name)
        out.parent.mkdir(exist_ok=True)
        with zipfile.ZipFile(self.zip) as src, zipfile.ZipFile(out, "w") as dst:
            for item in src.infolist():
                dst.writestr(item, src.read(item))
            for entry, data in extra.items():
                dst.writestr(entry, data)
        return out


class WhitelistTests(Fixture):
    def test_real_build_verifies(self):
        self.assertEqual(package_mod.verify(self.zip), [])
        self.assertEqual(self.zip.name, f"FactorioAccess_{VERSION}.zip")

    def test_real_build_has_every_migration(self):
        # A migration missing from the zip runs in a dev checkout and silently never for players.
        tracked = [f for f in package_mod.tracked_files() if f.startswith("migrations/")]
        self.assertTrue(tracked, "no migrations tracked; the test would prove nothing")
        with zipfile.ZipFile(self.zip) as z:
            shipped = {n.split("/", 1)[1] for n in z.namelist()}
        for f in tracked:
            self.assertIn(f, shipped)

    def test_real_build_has_no_native_or_installer(self):
        with zipfile.ZipFile(self.zip) as z:
            for n in z.namelist():
                self.assertIsNone(package_mod.forbidden(n.split("/", 1)[1]), n)
                parts = [p.lower() for p in n.split("/")]
                self.assertNotIn("native", parts)
                self.assertNotIn("installer", parts)

    def test_forbidden_entries_refused(self):
        top = f"FactorioAccess_{VERSION}"
        for entry in [
            f"{top}/fa_native.dll",
            f"{top}/scripts/version.dll",
            f"{top}/native/src/app.cpp",
            f"{top}/scripts/x.h",
            f"{top}/installer/src/main.rs",
            f"{top}/README.md",
            f"{top}/tools/package_mod.py",
            f"{top}/scripts/foo.exe",
            f"{top}/audio/x.pdb",
            "elsewhere/control.lua",
            f"{top}/../evil.lua",
        ]:
            with self.subTest(entry=entry):
                self.assertNotEqual(package_mod.verify(self.tampered({entry: b"x"})), [])

    def test_info_mismatch_refused(self):
        bad = self.tampered({}, name="FactorioAccess_9.9.9.zip")
        self.assertTrue(any("info.json" in p for p in package_mod.verify(bad)))


class GateTests(Fixture):
    def test_refusals(self):
        cases = [
            ("pull_request", f"refs/tags/v{VERSION}"),
            ("workflow_dispatch", f"refs/tags/v{VERSION}"),
            ("push", "refs/heads/f2.1"),
            ("push", "refs/heads/main"),
            ("push", "refs/tags/ci-latest"),
            ("push", "refs/tags/v1.2"),
            ("push", f"refs/tags/v{VERSION}-rc1"),
            ("push", f"refs/tags/v{VERSION}\n"),
            ("push", f"refs/tags/V{VERSION}"),
            ("push", f"refs/tags/x/v{VERSION}"),
            ("push", f"refs/heads/v{VERSION}"),
            ("push", "refs/tags/v999.0.0"),
            ("push", ""),
        ]
        for event, ref in cases:
            with self.subTest(event=event, ref=ref), env(event, ref):
                stub = mock.Mock()
                with self.assertRaises(portal.Refused):
                    portal.upload(self.zip, self.sha, dry_run=False, uploader=stub)
                stub.assert_not_called()

    def test_correct_tag_proceeds_to_the_stub(self):
        with env("push", f"refs/tags/v{VERSION}"):
            self.assertIn("DRY RUN", portal.upload(self.zip, self.sha, dry_run=True, uploader=mock.Mock()))
            stub = mock.Mock()
            portal.upload(self.zip, self.sha, dry_run=False, uploader=stub)
            stub.assert_called_once_with(self.zip, "fake")

    def test_correct_tag_but_bad_zip_refused(self):
        with env("push", f"refs/tags/v{VERSION}"):
            stub = mock.Mock()
            with self.assertRaises(portal.Refused):
                portal.upload(self.zip, "0" * 64, dry_run=False, uploader=stub)
            bad = self.tampered({f"FactorioAccess_{VERSION}/fa_native.dll": b"MZ"})
            bad_sha = hashlib.sha256(bad.read_bytes()).hexdigest()
            with self.assertRaises(portal.Refused):
                portal.upload(bad, bad_sha, dry_run=False, uploader=stub)
            stub.assert_not_called()


if __name__ == "__main__":
    unittest.main()
