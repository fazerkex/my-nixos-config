{ pkgs }:
let
  version = "0.1.10-nightly.20261116.4787";
  base = "https://github.com/pingdotgg/t3code/releases/download/v${version}";
  src = pkgs.fetchurl {
    url = "${base}/T3-Code-Nightly-x86_64.AppImage";
    hash = "sha256-5tr/FcF3zW0J+3Yav9YfeMJMC0tONKh2uD6l2I97llM=";
  };
  extracted = pkgs.appimageTools.extract {
    pname = "t3code-nightly";
    inherit version src;
  };
  desktop = pkgs.appimageTools.wrapType2 {
    pname = "t3code-nightly";
    inherit version;
    inherit src;
    extraPkgs = p: [
      p.libsecret
      p.kdePackages.kwallet
    ];
    extraInstallCommands = ''
      mkdir -p $out/share/applications $out/share/icons/hicolor/512x512/apps
      install -m644 ${extracted}/t3code.png $out/share/icons/hicolor/512x512/apps/t3code-nightly.png
      cat > $out/share/applications/t3code-nightly.desktop <<DESKTOP
      [Desktop Entry]
      Type=Application
      Name=T3 Code Nightly
      Exec=t3code-nightly %U
      StartupWMClass=com.t3tools.T3Code
      Icon=t3code-nightly
      Terminal=false
      Categories=Development;IDE;
      MimeType=x-scheme-handler/t3code;x-scheme-handler/t3code-dev;
      DESKTOP
    '';
  };
  # Node SEA embeds offsets in its ELF image; patchelf/strip corrupt them.
  # Run the untouched official bundle in an FHS environment instead.
  runtime = pkgs.stdenvNoCC.mkDerivation {
    pname = "t3-nightly-runtime";
    inherit version;
    src = pkgs.fetchurl {
      url = "${base}/t3-${version}-linux-x64.tar.gz";
      hash = "sha256-LJOlSHtc2Cl5JSH2Dk5J+gYSwbeTDNxfLJDnfvnF2hY=";
    };
    dontBuild = true;
    dontFixup = true;
    installPhase = "mkdir -p $out; cp -a . $out/";
  };
  cli = pkgs.buildFHSEnv {
    name = "t3";
    targetPkgs = p: [
      p.stdenv.cc.cc.lib
      p.zlib
      p.openssl
      p.vulkan-loader
      p.libsecret
      p.codex
      p.git
      p.gh
      p.tailscale
    ];
    runScript = "${runtime}/t3";
    extraInstallCommands = "";
  };
in
{
  inherit desktop cli version;
}
