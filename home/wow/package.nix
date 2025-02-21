{
  lib,
  pkgs,
}:

let
  version = "1.4.0";
  pname = "ascension-launcher";

  src = pkgs.fetchurl {
    url = "https://ascension.gg/launcher/Ascension-Launcher-${version}.AppImage";
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
}
