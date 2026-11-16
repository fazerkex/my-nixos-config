"""Exercise maintenance commands with mock executables; never activate or clean."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(os.environ.get("REPO_ROOT", Path(__file__).resolve().parents[1]))


class MaintenanceTests(unittest.TestCase):
    def run_script(self, script, *args):
        with tempfile.TemporaryDirectory() as directory:
            tmp = Path(directory)
            log = tmp / "commands"
            for name in ["nix", "nixos-rebuild", "sudo", "git", "nix-env", "hostname"]:
                command = tmp / name
                command.write_text(
                    "#!/bin/sh\n"
                    f"echo '{name}' \"$@\" >> \"$COMMAND_LOG\"\n"
                    + ("echo MKA-LAPTOP\n" if name == "hostname" else "")
                )
                command.chmod(0o755)
            env = dict(os.environ, PATH=f"{tmp}:{os.environ['PATH']}", COMMAND_LOG=str(log))
            result = subprocess.run(["bash", str(ROOT / script), *args], env=env,
                                    text=True, capture_output=True, check=False)
            return result, log.read_text().splitlines() if log.exists() else []

    def test_build_only_preserves_pins_and_never_activates_or_commits(self):
        result, calls = self.run_script("rebuild.sh", "-b")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(any(x.startswith("nix flake check") for x in calls))
        self.assertTrue(any(x.startswith("nixos-rebuild build") for x in calls))
        self.assertFalse(any("update" == x.split()[-1] for x in calls))
        self.assertFalse(any(x.startswith(("sudo", "git")) for x in calls))

    def test_updates_require_explicit_flag(self):
        result, calls = self.run_script("rebuild.sh", "-u", "-b")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("nix flake update", calls)

    def test_cleanup_dry_run_only_inspects(self):
        result, calls = self.run_script("clean.sh", "--dry-run", "30")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(calls, ["nix-env --list-generations --profile /nix/var/nix/profiles/system"])

    def test_invalid_retention_does_nothing(self):
        for value in ["0", "-1", "garbage"]:
            result, calls = self.run_script("clean.sh", value)
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(calls, [])


if __name__ == "__main__":
    unittest.main()
