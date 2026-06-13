{ config, pkgs, ... }: {
  imports = [ ./shell.nix ./packages.nix ./system.nix ];

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  
  users.users."mka" = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.fish; # Sets Fish as the system shell
  };
}