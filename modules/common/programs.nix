{ pkgs, ... }: {
    # These are managed by Home Manager.
    
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
            ];

            userSettings = {
                "keyboard.dispatch" = "keyCode";
                # Activate Material Icon Theme as the file icon theme
                "workbench.iconTheme" = "material-icon-theme";
            };

            keybindings = [
                {
                    key = "ctrl+#";
                    command = "editor.action.commentLine";
                    when = "editorTextFocus && !editorReadonly";
                }
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
        extensions = [
            { id = "lppmekppnliemjclknbagdhoocikieoi"; }   # 7TV
            { id = "ailoabdmgclmfmhdagmlohpjlbpffblp"; }   # Surfshark
            { id = "ghmbeldphafepmbegfdlkpapadhbakde"; }   # Proton Pass
        ];
    };
}