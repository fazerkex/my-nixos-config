{ config, pkgs, inputs, ... }: {
  imports = [ 
    inputs.plasma-manager.homeModules.plasma-manager
    ../../common/shortcuts.nix 
    ../../common/default_apps.nix
    ../../common/programs.nix
    ];
    
  home.stateVersion = "26.05";

  # Git config
  programs.git = {
    enable = true;
    settings = {
      user = { name = "maydin5"; email = "muhammed_kerim.aydin@smail.th-koeln.de"; };
      init = { defaultBranch = "main"; };
    };
  };

  # Desktop & Shell settings
  programs.plasma = {
    enable = true;
    kwin.virtualDesktops.number = 5;
    configFile.kdeglobals.General.TerminalApplication = "ghostty";
  };
  
  xdg.configFile."ghostty/config".text = ''
    font-family = "JetBrainsMono Nerd Font"
    font-size = 14
    theme = "Nord"
  '';
}