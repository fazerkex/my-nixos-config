{ pkgs, ... }:
    # to set Taskbar and Desktop apps
    
let
  braveDesktop = pkgs.makeDesktopItem {
    name = "mka-brave";
    desktopName = "Brave";
    exec = "brave";
    icon = "brave-browser";
    categories = [ "Network" "WebBrowser" ];
    startupWMClass = "brave-browser";
  };

  steamDesktop = pkgs.makeDesktopItem {
    name = "mka-steam";
    desktopName = "Steam";
    exec = "steam";
    icon = "steam";
    categories = [ "Game" ];
    startupWMClass = "steam";
  };

  vscodeDesktop = pkgs.makeDesktopItem {
    name = "mka-vscode";
    desktopName = "Visual Studio Code";
    exec = "code";
    icon = "vscode";
    categories = [ "Development" "IDE" ];
    startupWMClass = "Code";
  };

  systemMonitorDesktop = pkgs.makeDesktopItem {
    name = "mka-system-monitor";
    desktopName = "System Monitor";
    exec = "plasma-systemmonitor";
    icon = "utilities-system-monitor";
    categories = [ "System" "Monitor" ];
    startupWMClass = "plasma-systemmonitor";
  };

  dolphinDesktop = pkgs.makeDesktopItem {
    name = "mka-dolphin";
    desktopName = "Dolphin";
    exec = "dolphin";
    icon = "system-file-manager";
    categories = [ "System" "FileManager" ];
    startupWMClass = "dolphin";
  };

  localsendDesktop = pkgs.makeDesktopItem {
    name = "mka-localsend";
    desktopName = "LocalSend";
    exec = "localsend";
    icon = "localsend";
    categories = [ "Network" "FileTransfer" ];
    startupWMClass = "localsend";
  };
in
{
  # Make the custom desktop launchers available to Plasma.
  home.packages = [
    braveDesktop
    steamDesktop
    vscodeDesktop
    systemMonitorDesktop
    dolphinDesktop
    localsendDesktop
  ];

  # Replace the Plasma panel with one that has your pinned apps.
  programs.plasma.panels = [
    {
      location = "bottom";

      widgets = [
        {
          kickoff = {
            sortAlphabetically = true;
          };
        }

        {
          iconTasks = {
            launchers = [
              "applications:mka-brave.desktop"
              "applications:mka-steam.desktop"
              "applications:mka-vscode.desktop"
              "applications:mka-system-monitor.desktop"
              "applications:mka-dolphin.desktop"
              "applications:mka-localsend.desktop"
            ];

            appearance = {
              showTooltips = true;
            };
          };
        }

        { systemTray = { }; }

        {
          digitalClock = {
            calendar.firstDayOfWeek = "monday";
          };
        }
      ];
    }
  ];

  # Put real .desktop files on the desktop.
  home.file = {
    "Desktop/Brave.desktop" = {
      text = builtins.readFile "${braveDesktop}/share/applications/mka-brave.desktop";
      executable = true;
    };

    "Desktop/Steam.desktop" = {
      text = builtins.readFile "${steamDesktop}/share/applications/mka-steam.desktop";
      executable = true;
    };

    "Desktop/VS Code.desktop" = {
      text = builtins.readFile "${vscodeDesktop}/share/applications/mka-vscode.desktop";
      executable = true;
    };

    "Desktop/System Monitor.desktop" = {
      text = builtins.readFile "${systemMonitorDesktop}/share/applications/mka-system-monitor.desktop";
      executable = true;
    };

    "Desktop/Dolphin.desktop" = {
      text = builtins.readFile "${dolphinDesktop}/share/applications/mka-dolphin.desktop";
      executable = true;
    };

    "Desktop/LocalSend.desktop" = {
      text = builtins.readFile "${localsendDesktop}/share/applications/mka-localsend.desktop";
      executable = true;
    };
  };
}