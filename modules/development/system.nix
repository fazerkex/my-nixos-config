{ ... }:
{
  programs.nh = {
    enable = true;
    flake = "/home/mka/NixOS";
    # Keep one generation-retention policy: the existing Nix GC timer.
    clean.enable = false;
  };
}
