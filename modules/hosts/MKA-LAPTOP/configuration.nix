{ config, pkgs, ... }:

{
  imports = [
    ../../common/base.nix
    ./hardware.nix
  ];

  # Bootloader configuration (Required for system startup)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Network configuration
  networking.hostName = "MKA-LAPTOP";
  networking.networkmanager.enable = true;

  # Keyboard layout settings
  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };
  console.keyMap = "de";

  # Machine-specific user packages
  users.users."mka".packages = with pkgs; [
    kdePackages.kate
  ];

  # System state version (Do not change unless you know why)
  system.stateVersion = "26.05";
}
