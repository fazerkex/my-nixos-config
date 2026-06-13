{ config, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ./configuration.nix
  ];

  # Link your user to Home Manager
  home-manager.users."mka" = import ./home.nix;
}
