{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ../../ai/home.nix
    inputs.plasma-manager.homeModules.plasma-manager
    ../../common/shortcuts.nix
    ../../common/default_apps.nix
    ../../common/programs.nix
    ../../common/plasma_launchers.nix
  ];

  home.stateVersion = "26.05";

  # Git config
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

  # Desktop & Shell settings
  programs.plasma = {
    enable = true;
    kwin.virtualDesktops.number = 5;
    configFile.kdeglobals.General.TerminalApplication = "ghostty";
    input.touchpads = [
      {
        name = "Synaptics TM2438-005";
        vendorId = "06cb";
        productId = "5f41";

        naturalScroll = true;
        tapToClick = true;
        scrollMethod = "twoFingers";
      }
    ];
  };

  xdg.configFile."ghostty/config".text = ''
    font-family = "JetBrainsMono Nerd Font"
    font-size = 14
    theme = "Nord"
  '';
}
