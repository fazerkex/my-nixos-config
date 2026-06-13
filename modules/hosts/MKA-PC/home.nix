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

  # User Software
  home.packages = with pkgs; [
    ghostty
    neovim
    lazydocker
    btop
    ripgrep
    wl-clipboard
  ];

  # Custom Proton Mail Desktop App
  xdg.desktopEntries.protonmail = {
    name = "Proton Mail";
    exec = "brave --app=https://mail.proton.me";
    icon = "mail-message-new";
    terminal = false;
    categories = [ "Network" "WebBrowser" ];
  };

  # KDE Plasma Declarative Settings
  programs.plasma = {
    enable = true;

    configFile.kdeglobals.General.TerminalApplication = "ghostty";

    shortcuts = {
      "kwin" = {
        "Switch to Desktop 1" = "Meta+1";
        "Switch to Desktop 2" = "Meta+2";
        "Switch to Desktop 3" = "Meta+3";
        "Switch to Desktop 4" = "Meta+4";
        "Switch to Desktop 5" = "Meta+5";
        "Switch to Desktop 6" = "Meta+6";
        "Switch to Desktop 7" = "Meta+7";
        "Window Close" = "Meta+W";
      };

      "services/com.mitchellh.ghostty.desktop" = { "_launch" = "Meta+Return"; };
      "services/org.kde.dolphin.desktop" = { "_launch" = "Meta+F"; };
      "services/brave-browser.desktop" = { "_launch" = "Meta+B"; };
      "services/code.desktop" = { "_launch" = "Meta+V"; };
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
