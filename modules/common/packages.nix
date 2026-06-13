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
    zoxidem
    git
    nano
    python3 
    sops 
    fastfetch 
    fzf 
    bat 
    direnv 
  ];
  
  fonts.packages = with pkgs; [ 
    nerd-fonts.symbols-only 
    nerd-fonts.jetbrains-mono 
  ];

  programs.vscode = {enable = true;};

  programs.brave = {enable = true;};


}
