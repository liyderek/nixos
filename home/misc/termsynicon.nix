{ pkgs }:
pkgs.runCommand "myfont" { } ''
  mkdir -p $out/share/fonts/truetype
  cp ${./termsynicon/termsynicon.ttf} $out/share/fonts/truetype/
''
