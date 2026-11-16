# AI environment on MKA-LAPTOP

Configuration is for mka, x86_64-linux, /home/mka/NixOS. The existing
nixos-unstable revision, Plasma desktop, hardware, boot and storage are preserved.
Codex remains the single system package (0.167.1 at inspection); authenticated
ChatGPT login was confirmed. Its account cache lists gpt-6.1-sol, gpt-6-astra,
gpt-6.1-terra and others. Use `/model` in Codex or T3's model picker to choose;
no model or authentication file is overwritten.

## Review and activate (requires explicit approval)

New files must be tracked before using the Git flake. Review and add just the
intended files, then build again:

```sh
git add flake.nix flake.lock modules/common/packages.nix modules/hosts/MKA-LAPTOP/home.nix modules/ai modules/networking packages AI-ENVIRONMENT.md
nix flake check
nix build .#nixosConfigurations.MKA-LAPTOP.config.system.build.toplevel
# Only after approving activation, service and firewall changes:
sudo nixos-rebuild switch --flake .#MKA-LAPTOP
```

The repository's `rebuild` now preserves pins and validates before activation;
`rebuild -b` only builds. `update` explicitly refreshes inputs. See DEVELOPMENT.md.
The initial AI configuration was activated after approval; later edits require
a further approved rebuild.
The system switch enables tailscaled, but does not sign in or enable routing.
Home Manager merges the two MCP registrations and workspace-write/on-request
permissions into writable Codex config, making a private initial backup at
~/.codex/config.toml.before-ai-setup. It does not read or replace auth.json.
`ai-configure-codex` repeats that merge if needed. Existing unrelated settings
are retained. MCP calls require prompts; sudo still requires a password.
The local nixos-safe skill adapts upstream workflow to approval requirements;
upstream's autonomous-switch companion skills are intentionally not installed.

## Desktop and provider setup

Launch **T3 Code Nightly** or `t3code-nightly`. CLI: `t3 --help`.
Use the existing Codex login; if it expires run `codex login` interactively.
Check `type -a codex`, `codex --version`, `codex login status`, `codex mcp list`.
In T3 select Codex and its model in provider settings. Restart Codex/T3 after
activation to pick up MCP servers. Use `/mcp`, then request a nix-agent
`eval_config` for `networking.hostName` and mcp-nixos package search.

## Remote access (separate explicit approval)

Sign both devices into the same tailnet:

```sh
sudo tailscale up
```

Follow its browser login. No auth key is in Nix. No exit node, advertised route,
Funnel, public firewall port or trusted-interface bypass is configured.

Simplest T3 Connect mode: keep the desktop running, open **Settings → Sharing &
access**, sign in and enable **T3 Connect**, then enable **Require approval for
new devices**. Sign into the same account at https://app.t3.codes on your phone
or other computer and select this environment. Check matching approval codes.
Credentials and renewed tunnel credentials stay in user data outside Git/store.
Closing the last desktop window stops its local server.

For a background host, a declarative `t3code-nightly.service` is supplied but
has no automatic startup target. First turn off desktop **Settings → Environments
→ Local environment** to avoid running two hosts on the same data. After approval:

```sh
systemctl --user start t3code-nightly
systemctl --user status t3code-nightly
journalctl --user -u t3code-nightly
```

Connect linking can be managed through Sharing & access on that host. For login
startup after approval, add `Install.WantedBy = [ "default.target" ];` to this
Home Manager unit and rebuild. Lingering is not configured. Do not run `t3 up`
or `t3 service install` alongside this unit: upstream creates its own service,
mutable runtime and Linux lingering. Prefer the desktop flow until linking the
custom service has been verified interactively.

The custom service binds 127.0.0.1:3773. For private Tailscale HTTPS after approval,
enable MagicDNS/HTTPS certificates in your tailnet, then as an administrator:

```sh
sudo tailscale serve --bg http://127.0.0.1:3773
```

Generate an authenticated T3 pairing link for the resulting HTTPS tailnet URL
using Sharing & access. Pairing is still required. Do not enable Funnel or LAN
listening. Remove that mapping with `sudo tailscale serve --https=443 --set-path=/ off`.
No operator permission is granted to T3; the administrator controls Serve.
Keep the machine awake and logged in for access; no lingering was enabled.

## Updating and rollback

Official artifacts are pinned in packages/t3code-nightly.nix. Inspect
https://github.com/pingdotgg/t3code/releases for a new nightly, select matching
x86_64 AppImage and linux-x64 CLI tarball, replace version and BOTH hashes.
Use asset SHA-256 digests converted to SRI (`nix hash convert --hash-algo sha256
--to sri <hex>`), or `nix store prefetch-file --json <exact asset URL>` and compare.
Build, check versions and inspect the diff before approving activation. Do not use
`t3 update` to replace the declarative package. Update nix-agent with
`nix flake update nix-agent`; the main nixpkgs pin is independent and unchanged.

Before activation, rollback is just reverting these reviewed configuration edits.
After activation, inspect `sudo nix-env -p /nix/var/nix/profiles/system --list-generations`.
With approval use `sudo nixos-rebuild switch --rollback`, or select a retained
previous boot generation. Do not delete generations. User config and credentials
are not rolled back by NixOS: restore the private Codex config backup if desired,
and revoke T3 Connect/Tailscale sessions separately. Existing automatic garbage
collection can remove older generations; retain any generation needed for rollback.

Sources:
- https://github.com/pingdotgg/t3code/blob/main/docs/user/remote-access.md
- https://github.com/pingdotgg/t3code/blob/main/docs/user/background-service.md
- https://github.com/JEFF7712/nix-agent/blob/main/docs/agent-install.md
- https://github.com/utensils/mcp-nixos
- https://developers.openai.com/codex/config-reference
- https://tailscale.com/kb/

## Validation performed

- All changed Nix files passed nixfmt checks; Git diff passed whitespace checks.
- `nix flake check path:/home/mka/NixOS` passed.
- Full non-activating system build passed; result is /tmp/ai-upstream/system.
- Built CLI reports `t3 v0.1.10-nightly.20261116.4787`; serve help runs.
- Official desktop artifact downloaded with the pinned hash and built successfully.
- Codex reports 0.167.1 and existing ChatGPT login is valid; package left unchanged.
- nix-agent package 0.14.1 and mcp-nixos 3.0.2 both completed stdio MCP
  initialization and tools/list. No privileged tool was invoked.
- Generated tailscaled unit is enabled under multi-user.target; Tailscale package
  is 1.104.6. Public TCP/UDP firewall port lists are empty. Existing wheel sudo
  rules still require authentication; no NOPASSWD rules were added.
- Generated T3 unit has loopback bind, restart-on-failure and no startup target.
- Codex merge tested in an isolated temporary directory: idempotent, retained
  model and unrelated config, auth unchanged, config permissions 0600.

The initial CLI patching approach failed its runtime version probe (Node SEA
resource assertion); the final package preserves the executable unchanged in an
FHS environment and passes that probe. nix-agent's FastMCP dependency is scoped
to MCP 1.x, matching nixpkgs' mcp-nixos compatibility fix.

Not yet verified: GUI rendering, keyring access from Electron, account model
refresh, MCP discovery inside a newly launched Codex/T3 session, actual build-tool
calls through MCP, Tailscale login/connectivity, Connect pairing, and background
service runtime. These require activation and/or interactive credentials. No
services, firewall state, remote access, sudo configuration or login state were
activated or modified during validation.

## Legacy T3 installation

The former nixpkgs `t3code` entry has been removed from the system package
list. Only the pinned Nightly desktop and CLI are installed by this flake.
The hidden `com.t3tools.T3Code.desktop` file created by Nightly itself is
not a second installation. T3 protocol links are associated declaratively
with `t3code-nightly.desktop`, which runs the NixOS-compatible wrapper.
Older NixOS generations may retain the former package for rollback; they
are not active installations and should not be deleted as application cleanup.
