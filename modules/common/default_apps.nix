{ pkgs, ... }: {
    # Default Applications
    xdg.mimeApps = {
        enable = true;
        defaultApplications = {
            "text/html" = "brave-browser.desktop";
            "x-scheme-handler/http" = "brave-browser.desktop";
            "x-scheme-handler/https" = "brave-browser.desktop";
            "text/plain" = "code.desktop";
        };
    };

}