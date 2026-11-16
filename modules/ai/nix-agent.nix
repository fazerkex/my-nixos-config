{ inputs, pkgs, ... }:
let
  # FastMCP 3 requires MCP 1.x; mirror nixpkgs' mcp-nixos compatibility scope.
  python = pkgs.python3Packages.overrideScope (final: prev: { mcp = final.mcp_1; });
in
{
  imports = [ inputs.nix-agent.nixosModules.default ];
  programs.nix-agent = {
    enable = true;
    package = inputs.nix-agent.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
      propagatedBuildInputs = [ python.fastmcp ];
    });
    flake = "/home/mka/NixOS";
    privilegedAutomation.enable = false;
  };
  environment.systemPackages = [ pkgs.mcp-nixos ];
}
