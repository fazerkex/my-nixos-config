{ config, pkgs, inputs, ... }:

{
  # Import Plasma Manager
  imports = [
    inputs.plasma-manager.homeManagerModules.plasma-manager
  ];

  home.stateVersion = "26.05";

  # User Software & Recommendations
  home.packages = with pkgs; [
    ghostty       # Your new terminal
    neovim        # The modern vim
    lazydocker    # The ultimate Docker TUI (run 'lazydocker' in terminal)

    # --- Highly Recommended Extras ---
    btop          # A gorgeous, highly detailed task manager (run 'btop')
    ripgrep       # Ultra-fast search tool (crucial for Neovim plugins)
    wl-clipboard  # Allows Neovim and terminal apps to copy/paste to Wayland
  ];

  # Create a custom app for Proton Mail Webapp
  xdg.desktopEntries.protonmail = {
    name = "Proton Mail";
    exec = "brave --app=https://mail.proton.me";
    icon = "mail-message-new";
    terminal = false;
    categories = [ "Network" "WebBrowser" ];
  };

  # KDE Plasma Declarative Settings & Keybindings
  programs.plasma = {
    enable = true;

    # Set Ghostty as the default KDE terminal
    configFile.kdeglobals.General.TerminalApplication = "ghostty";

    shortcuts = {
      # Window Management
      "kwin" = {
        "Switch to Desktop 1" = "Meta+1";
        "Switch to Desktop 2" = "Meta+2";
        "Switch to Desktop 3" = "Meta+3";
        "Switch to Desktop 4" = "Meta+4";
        "Window Close" = "Meta+W";
      };

      # App Launchers (Mapping to their .desktop files)
      "services/com.mitchellh.ghostty.desktop" = "Meta+Return";
      "services/org.kde.dolphin.desktop" = "Meta+F";
      "services/brave-browser.desktop" = "Meta+B";
      "services/code.desktop" = "Meta+V";
      "services/protonmail.desktop" = "Meta+M";
    };
  };

  # VS Code
  programs.vscode = {
    enable = true;
  };

  # Brave with Touchpad Swipes
  programs.brave = {
    enable = true;
    commandLineArgs = [
      "--ozone-platform-hint=auto"
      "--enable-features=TouchpadOverscrollHistoryNavigation"
    ];
  };

  # Force Default XDG Apps
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
