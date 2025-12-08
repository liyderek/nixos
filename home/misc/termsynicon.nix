{ pkgs }:
pkgs.stdenv.mkDerivation {
  name = "termsynicon";
  src = ./termsynicon.tar.xz;
  installPhase = ''
    mkdir -p $out/share/fonts/truetype/
    install -Dm644 termsynicon.ttf $out/share/fonts/truetype/
  '';
}
