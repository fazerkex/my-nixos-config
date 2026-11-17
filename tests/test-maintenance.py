"""Exercise maintenance commands with mock executables; never activate or clean."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(os.environ.get("REPO_ROOT", Path(__file__).resolve().parents[1]))


class MaintenanceTests(unittest.TestCase):
    def run_script(self, script, *args, fail_build=False):
        with tempfile.TemporaryDirectory() as directory:
            tmp = Path(directory)
            log = tmp / "commands"
            for name in ["nix", "nixos-rebuild", "sudo", "git", "nix-env", "hostname"]:
                command = tmp / name
                command.write_text(
                    "#!/bin/sh\n"
                    f"echo '{name}' \"$@\" >> \"$COMMAND_LOG\"\n"
                    + ("echo MKA-LAPTOP\n" if name == "hostname" else "")
                    + ('if [ "$1" = diff ] && [ "$2" = --cached ]; then exit 1; fi\n' if name == "git" else "")
                    + ("exit 1\n" if name == "nixos-rebuild" and fail_build else "")
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

    def test_commit_and_push_follow_successful_build(self):
        result, calls = self.run_script("rebuild.sh", "-b", "-c", "reviewed change", "-p")
        self.assertEqual(result.returncode, 0, result.stderr)
        build = next(i for i, x in enumerate(calls) if x.startswith("nixos-rebuild build"))
        commit = calls.index("git commit -m reviewed change")
        self.assertLess(build, commit)
        self.assertLess(commit, calls.index("git push"))
        self.assertFalse(any(x.startswith(("sudo", "git add")) for x in calls))

    def test_failed_build_never_commits_or_pushes(self):
        result, calls = self.run_script("rebuild.sh", "-b", "-c", "change", "-p", fail_build=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(any(x.startswith(("git commit", "git push", "sudo")) for x in calls))

    def test_push_requires_explicit_commit(self):
        result, calls = self.run_script("rebuild.sh", "-p")
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(any(x.startswith(("nix ", "sudo", "git push")) for x in calls))

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
