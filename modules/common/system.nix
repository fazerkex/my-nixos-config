{ pkgs, ... }: {
  # Nix core settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  
  # Desktop & Sound services
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.printing.enable = true;
  services.pipewire = { enable = true; alsa.enable = true; pulse.enable = true; };
  
  # Virtualization & Input
  virtualisation.docker.enable = true;
  services.libinput = { enable = true; touchpad.naturalScrolling = true; };
  
  # Maintenance (Auto-GC)
  nix.gc = { automatic = true; dates = "weekly"; options = "--delete-older-than 14d"; };
  nix.settings.auto-optimise-store = true;

  home-manager.backupFileExtension = "bak";
}