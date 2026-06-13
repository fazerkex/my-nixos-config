{ pkgs, ... }: {

    programs.vscode = {
        enable = true;
        profiles.default = {
            extensions = with pkgs.vscode-extensions; [
                bbenoist.nix
                ms-python.python
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
}