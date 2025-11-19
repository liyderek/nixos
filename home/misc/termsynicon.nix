{ pkgs }:
pkgs.stdenv.mkDerivation {
  name = "termsynicon";
  src = ./termsynicon.tar.xz;
  installPhase = ''
    mkdir -p $out/share/fonts/TTF
    cp termsynicon.ttf $out/share/fonts/TTF/
  '';
}
