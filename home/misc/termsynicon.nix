{ pkgs }:
pkgs.stdenv.mkDerivation {
  name = "termsynicon";
  src = ./termsynicon.ttf;
  installPhase = ''
    mkdir -p $out/share/fonts/TTF
    cp MyConsoleFont.ttf $out/share/fonts/TTF/
  '';
}
