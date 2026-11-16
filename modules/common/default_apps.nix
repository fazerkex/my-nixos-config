{ pkgs, ... }: {
  # Default Applications
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/t3code" = "t3code-nightly.desktop";
      "x-scheme-handler/t3code-dev" = "t3code-nightly.desktop";
      "text/html" = "brave-browser.desktop";
      "x-scheme-handler/http" = "brave-browser.desktop";
      "x-scheme-handler/https" = "brave-browser.desktop";
      "text/plain" = "code.desktop";
    };
  };

}
