{ pkgs, ... }: {
  programs.fish = {
    enable = true;
    # Disable the fish welcome message for a cleaner terminal
    interactiveShellInit = "set -g fish_greeting \"\"";
    
    # Map 'cd' to 'z' (zoxide) and add the rebuild alias
    shellAliases = {
      cd = "z";
      rebuild = "/home/mka/NixOS/rebuild.sh";
    };
  };

  # Hook zoxide and starship into Fish
  programs.zoxide = { enable = true; enableFishIntegration = true; };
  programs.starship = { enable = true; enableFishIntegration = true; };
}