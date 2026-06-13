{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [ 
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
}