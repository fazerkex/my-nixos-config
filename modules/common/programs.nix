{ pkgs, ... }: {

    programs.vscode = {
        enable = true;
        profiles.default = {
            extensions = with pkgs.vscode-extensions; [
                bbenoist.nix
                ms-python.python
                redhat.vscode-yaml
                tomoki1207.pdf
                ms-vscode.cpptools
                pkief.material-icon-theme
                donjayamanne.githistory
                # Add other extensions here...
            ];
        };
  };

    # Brave Browser
    programs.brave = {
        enable = true;
        commandLineArgs = [
            "--ozone-platform-hint=auto"
            "--enable-features=TouchpadOverscrollHistoryNavigation"
        ];
    };

    # Brave extensions
    programs.chromium = {
        enable = true;
        package = pkgs.brave;
        extensions = [
            { id = "lppmekppnliemjclknbagdhoocikieoi"; }   # 7TV
            { id = "ailoabdmgclmfmhdagmlohpjlbpffblp"; }   # Surfshark
            { id = "ghmbeldphafepmbegfdlkpapadhbakde"; }   # Proton Pass
        ];
  };
}