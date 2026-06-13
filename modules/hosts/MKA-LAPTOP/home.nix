{ config, pkgs, inputs, ... }:

{
  imports = [
    inputs.plasma-manager.homeModules.plasma-manager
  ];

  home.stateVersion = "26.05";

  # Git Configuration
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "maydin5";
        email = "muhammed_kerim.aydin@smail.th-koeln.de";
      };
      init = {
        defaultBranch = "main";
      };
    };
  };

  programs.fish = {
    enable = true;
    # Your rebuild alias
    shellAliases = {
      rebuild = "~/NixOS/rebuild.sh";
    };
  };

  # Make sure zoxide and starship hook into Fish
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };

  # User Software
  home.packages = with pkgs; [
    ghostty
    neovim
    lazydocker
    btop
    ripgrep
    wl-clipboard
    gh
    localsend
    steam
    libinput-gestures
    fastfetch
    fzf
    bat
    zoxide
    starship
    direnv
  ];

  # Custom Proton Mail Desktop App
  xdg.desktopEntries.protonmail = {
    name = "Proton Mail";
    exec = "brave --app=https://mail.proton.me";
    icon = "mail-message-new";
    terminal = false;
    categories = [ "Network" "WebBrowser" ];
  };

  # Ghosty config
  xdg.configFile."ghostty/config".text = ''
    font-family = "JetBrainsMono Nerd Font"
    font-size = 12
    theme = "nord"
  '';

  # KDE Plasma Declarative Settings
  programs.plasma = {
    enable = true;

    # Force KDE to generate 4 virtual desktops
    kwin.virtualDesktops.number = 4;

    configFile.kdeglobals.General.TerminalApplication = "ghostty";

    shortcuts = {
      # --- explicitly unbind conflicting defaults ---
      "plasmashell" = {
        "activate task manager entry 1" = [ ];
        "activate task manager entry 2" = [ ];
        "activate task manager entry 3" = [ ];
        "activate task manager entry 4" = [ ];
        # We removed the clipboard_action override, so Meta+V naturally opens the clipboard again!
      };

      # Kill the Power Profile shortcut
      "powerdevil" = {
        "Switch to Power Saver" = [ ];
        "Switch to Balanced" = [ ];
        "Switch to Performance" = [ ];
        "Toggle Power Profile" = [ ]; # This is the one grabbing Meta+B
      };

      "kwin" = {
        "Overview" = [ ]; # Frees up Meta+W
        
        # --- your custom window management ---
        "Switch to Desktop 1" = "Meta+1";
        "Switch to Desktop 2" = "Meta+2";
        "Switch to Desktop 3" = "Meta+3";
        "Switch to Desktop 4" = "Meta+4";
        "Window Close" = "Meta+W";
      };
      
      # --- your custom app launchers ---
      "services/com.mitchellh.ghostty.desktop" = { "_launch" = "Meta+Return"; };
      "services/org.kde.dolphin.desktop" = { "_launch" = "Meta+F"; };
      "services/brave-browser.desktop" = { "_launch" = "Meta+B"; };
      "services/code.desktop" = { "_launch" = "Meta+C"; }; 
      "services/protonmail.desktop" = { "_launch" = "Meta+M"; };
    };
  };

  # VS Code
  programs.vscode = {
    enable = true;
  };

  # Brave Browser
  programs.brave = {
    enable = true;
    commandLineArgs = [
      "--ozone-platform-hint=auto"
      "--enable-features=TouchpadOverscrollHistoryNavigation"
    ];
  };

  # Default Applications
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "brave-browser.desktop";
      "x-scheme-handler/http" = "brave-browser.desktop";
      "x-scheme-handler/https" = "brave-browser.desktop";
      "text/plain" = "code.desktop";
    };
  };
}
