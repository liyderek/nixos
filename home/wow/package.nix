{
  lib,
  pkgs,
}:

let
  version = "1.4.0";
  pname = "ascension-launcher";

  src = ./ascension-launcher-145.AppImage;

  appimageContents = pkgs.appimageTools.extractType1 {
    inherit src;
    name = "ascension";
  };
in
pkgs.appimageTools.wrapType2 rec {
  inherit pname version src;

  extraInstallCommands = ''
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=${meta.mainProgram}'
  '';

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
