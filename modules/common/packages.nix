{ pkgs, ... }: {
    # These are managed by NixOS.
    
  environment.systemPackages = with pkgs; [
    ghostty
    neovim
    lazydocker
    btop
    ripgrep
    wl-clipboard
    gh
    localsend
    #steam
    libinput
    libinput-gestures
    starship
    zoxide
    git
    nano
    python3 
    sops 
    fastfetch 
    fzf 
    bat 
    direnv
    brave
    libreoffice
    onlyoffice-desktopeditors
    t3code
    opencode
    codex
  ];
  
  fonts.packages = with pkgs; [ 
    nerd-fonts.symbols-only 
    nerd-fonts.jetbrains-mono 
  ];

  # Steam
    programs.steam.enable = true;
}
