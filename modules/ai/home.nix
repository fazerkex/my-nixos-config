{ pkgs, lib, ... }:
let
  t3 = import ../../packages/t3code-nightly.nix { inherit pkgs; };
  python = pkgs.python3.withPackages (p: [ p.tomlkit ]);
  configure = pkgs.writeShellScriptBin "ai-configure-codex" ''
    exec ${python}/bin/python ${./merge-codex.py}
  '';
in
{
  home.packages = [
    t3.desktop
    t3.cli
    configure
  ];
  # Keep config.toml writable for Codex/T3; merge only these managed settings.
  home.activation.aiCodex = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${configure}/bin/ai-configure-codex
  '';
  home.file.".codex/skills/nixos-safe/SKILL.md".text = ''
    ---
    name: nixos-safe
    description: Manage this machine's NixOS flake using nix-agent and mcp-nixos with human approval for activation.
    ---
    Configuration: /home/mka/NixOS, host MKA-LAPTOP, user mka.
    Home Manager is integrated into NixOS; build the whole system.
    Use mcp-nixos for package/option discovery; nix-agent for eval_config,
    locate_option, build, diff, check, and generation inspection.
    Edit declarative files with ordinary workspace tools. Preserve unrelated edits.
    Builds, evaluation and flake checks may run automatically. Inspect diffs.
    Obtain explicit user approval before activation, switch, boot, test,
    dry-activate, rollback, firewall changes, sudo changes or persistent remote access.
    Never enable passwordless sudo. Do not bypass prompts with shell commands.
    Inspect generations and explain rollback before proposing it. Never delete generations.
    Use existing sops-nix for secrets; never put credentials in Git or the Nix store.
    Upstream companion skills assume autonomous switching; this local adaptation
    deliberately requires approval instead.
  '';
  # Prepared only. No WantedBy, automatic start, or lingering.
  systemd.user.services.t3code-nightly = {
    Unit = {
      Description = "T3 Code Nightly host (loopback only)";
      After = [ "network.target" ];
    };
    Service = {
      ExecStart = "${t3.cli}/bin/t3 serve";
      Environment = [
        "T3CODE_HOST=127.0.0.1"
        "T3CODE_PORT=3773"
      ];
      EnvironmentFile = "-%h/.config/t3code-nightly/service.env";
      WorkingDirectory = "%h";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
