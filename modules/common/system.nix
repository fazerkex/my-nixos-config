{ config, pkgs, ... }: {
  # Nix core settings
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;

  # Desktop & Sound services
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.printing.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # Virtualization & Input
  virtualisation.docker = {
    enable = false;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };
  services.libinput = {
    enable = true;
    touchpad.naturalScrolling = true;
  };

  # Maintenance (Auto-GC)
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nix.settings.auto-optimise-store = true;

  home-manager.backupFileExtension = "bak";

  # SOPS + Wi-Fi
  sops = {
    defaultSopsFile = ../../secrets/wifi.yaml;
    defaultSopsFormat = "yaml";

    age = {
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };

    secrets = {
      wifi_aydin_ssid = { };
      wifi_aydin2_ssid = { };
      wifi_shared_psk = { };
    };

    templates."wifi.env".content = ''
      AYDIN_SSID="${config.sops.placeholder.wifi_aydin_ssid}"
      AYDIN2_SSID="${config.sops.placeholder.wifi_aydin2_ssid}"
      WIFI_PSK="${config.sops.placeholder.wifi_shared_psk}"
    '';
  };

  networking.networkmanager.ensureProfiles = {
    environmentFiles = [ config.sops.templates."wifi.env".path ];

    profiles = {
      "Aydin" = {
        connection = {
          id = "Aydin";
          type = "wifi";
          autoconnect = true;
        };
        wifi = {
          mode = "infrastructure";
          ssid = "$AYDIN_SSID";
        };
        wifi-security = {
          auth-alg = "open";
          key-mgmt = "wpa-psk";
          psk = "$WIFI_PSK";
        };
        ipv4.method = "auto";
        ipv6.method = "auto";
      };

      "Aydin 2" = {
        connection = {
          id = "Aydin 2";
          type = "wifi";
          autoconnect = true;
        };
        wifi = {
          mode = "infrastructure";
          ssid = "$AYDIN2_SSID";
        };
        wifi-security = {
          auth-alg = "open";
          key-mgmt = "wpa-psk";
          psk = "$WIFI_PSK";
        };
        ipv4.method = "auto";
        ipv6.method = "auto";
      };
    };
  };
}
