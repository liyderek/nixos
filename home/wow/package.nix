{
  lib,
  pkgs,
}:

let
  version = "1.4.6";
  pname = "ascension-launcher";

  src = pkgs.fetchurl {
    url = "https://api.ascension.gg/api/bootstrap/launcher/latest?unix";
    sha256 = "sha256-Ul67zJFpdLXeT5d0RC2ZyEeyQQBtQkYqoLykT4aVNCU=";
  };
in
pkgs.appimageTools.wrapType2 rec {
  inherit pname version src;

  meta = {
    description = "Ascension Launcher";
    homepage = "https://ascension.gg";
    downloadPage = "https://ascension.gg";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
  };

  extraPkgs = with pkgs; [
    glib
    glibc
    gtk3
    libX11
    libXcomposite
    libXcursor
    libXdamage
    libXext
    libXfixes
    libXi
    libXrandr
    libXrender
    libXtst
    libappindicator-gtk3
    libasound
    libnotify
    libnss
    libxkbcommon
    libxkbcommon-x11
    pango
    zlib
  ];
}
