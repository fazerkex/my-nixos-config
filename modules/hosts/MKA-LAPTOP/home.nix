{ config, pkgs, inputs, ... }: {
  imports = [ 
    inputs.plasma-manager.homeModules.plasma-manager
    ../../common/shortcuts.nix ];
    
  home.stateVersion = "26.05";

  # Git config
  programs.git = {
    enable = true;
    settings = {
      user = { name = "maydin5"; email = "muhammed_kerim.aydin@smail.th-koeln.de"; };
      init = { defaultBranch = "main"; };
    };
  };

  # Your apps
  home.packages = with pkgs; [ ghostty neovim lazydocker ripgrep wl-clipboard gh localsend steam libinput-gestures fastfetch fzf bat direnv sops ];

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