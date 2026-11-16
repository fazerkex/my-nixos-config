"""Merge declarative MCP settings without copying credentials into the store."""
import os
from pathlib import Path
import shutil
import tempfile
import tomlkit

root = Path(os.environ.get("CODEX_HOME", str(Path.home() / ".codex")))
root.mkdir(parents=True, exist_ok=True)
path = root / "config.toml"
original = path.read_text() if path.exists() else ""
config = tomlkit.parse(original)
config["approval_policy"] = "on-request"
config["sandbox_mode"] = "workspace-write"
servers = config.setdefault("mcp_servers", tomlkit.table())
for name, command in [("nix-agent", "/run/current-system/sw/bin/nix-agent"),
                      ("mcp-nixos", "/run/current-system/sw/bin/mcp-nixos")]:
    server = servers.setdefault(name, tomlkit.table())
    server["command"] = command
    server["args"] = []
    server["default_tools_approval_mode"] = "prompt"
result = tomlkit.dumps(config)
if result != original:
    if path.exists():
        backup = root / "config.toml.before-ai-setup"
        if not backup.exists():
            shutil.copy2(path, backup)
            backup.chmod(0o600)
    fd, temporary = tempfile.mkstemp(dir=root, prefix=".config-")
    with os.fdopen(fd, "w") as output:
        output.write(result)
    os.replace(temporary, path)
