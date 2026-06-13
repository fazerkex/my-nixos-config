{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
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
  ];
  
  fonts.packages = with pkgs; [ 
    nerd-fonts.symbols-only 
    nerd-fonts.jetbrains-mono 
  ];
}
