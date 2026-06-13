{ pkgs, ... }: {
  programs.plasma.shortcuts = {
    "Power Management" = {
       "Switch Power Profile" = [ ];
    };

    "plasmashell" = {
      "activate task manager entry 1" = [ ];
      "activate task manager entry 2" = [ ];
      "activate task manager entry 3" = [ ];
      "activate task manager entry 4" = [ ];
      "activate task manager entry 5" = [ ];
    };
    "kwin" = {
      "Overview" = [ ];
      "Switch to Desktop 1" = "Meta+1";
      "Switch to Desktop 2" = "Meta+2";
      "Switch to Desktop 3" = "Meta+3";
      "Switch to Desktop 4" = "Meta+4";
      "Switch to Desktop 5" = "Meta+5";
      "Window Close" = "Meta+W";
    };
    "services/com.mitchellh.ghostty.desktop" = { "_launch" = "Meta+Return"; };
    "services/org.kde.dolphin.desktop" = { "_launch" = "Meta+F"; };
    "services/brave-browser.desktop" = { "_launch" = "Meta+B"; };
    "services/code.desktop" = { "_launch" = "Meta+C"; };
    "services/protonmail.desktop" = { "_launch" = "Meta+M"; };
  };
}