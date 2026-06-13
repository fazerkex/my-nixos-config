{ pkgs, ... }: {

    programs.vscode = {
        enable = true;
        extensions = with pkgs.vscode-extensions; [
            bbenoist.nix          # For Nix language support
            ms-python.python      # For Python
            # Add more here...
        ];
    };

    # Brave Browser
    programs.brave = {
        enable = true;
        commandLineArgs = [
            "--ozone-platform-hint=auto"
            "--enable-features=TouchpadOverscrollHistoryNavigation"
        ];
    };

    xdg.desktopEntries.protonmail = {
        name = "Proton Mail";
        exec = "brave --app=https://mail.proton.me";
        icon = "mail-message-new"; # You might need to pick an icon installed on your system
        terminal = false;
        categories = [ "Network" "WebBrowser" ];
    };
}