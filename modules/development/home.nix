{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nixd
    nixfmt
    statix
    deadnix
    shellcheck
    jq
    fd
  ];
  # The NixOS module owns the login shell; HM owns user hook configuration.
  programs.fish.enable = true;
  programs.direnv = {
    enable = true;
    enableFishIntegration = true;
    nix-direnv.enable = true;
  };
}
