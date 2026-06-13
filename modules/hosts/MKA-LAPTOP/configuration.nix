{ config, pkgs, ... }: {
  imports = [ ../../common/base.nix ./hardware.nix ];

  networking.hostName = "MKA-LAPTOP";
  networking.networkmanager.enable = true;

  # Keyboard setup
  services.xserver.xkb = { layout = "de"; variant = ""; };
  console.keyMap = "de";

  # Only machine-specific packages go here
  users.users."mka".packages = with pkgs; [ kdePackages.kate ];

  system.stateVersion = "26.05";
}