{ pkgs, ... }:
let
  python = pkgs.python3.withPackages (ps: [ ps.pygobject3 ]);
  sleepScreen = pkgs.stdenvNoCC.mkDerivation {
    pname = "niri-sleep-screen";
    version = "1.0";
    src = ./sleep-screen.py;
    dontUnpack = true;
    strictDeps = true;
    nativeBuildInputs = [
      pkgs.wrapGAppsHook3
      pkgs.gobject-introspection
    ];
    buildInputs = [
      python
      pkgs.gtk3
      pkgs.gtk-layer-shell
    ];
    installPhase = ''
      runHook preInstall
      install -Dm755 "$src" "$out/bin/niri-sleep-screen"
      substituteInPlace "$out/bin/niri-sleep-screen" \
        --replace-fail '#!/usr/bin/env python3' '#!${python}/bin/python3' \
        --replace-fail '@MPV@' '${pkgs.mpv}/bin/mpv'
      runHook postInstall
    '';
    preFixup = ''
      gappsWrapperArgs+=(--set GDK_BACKEND wayland)
    '';
    meta.mainProgram = "niri-sleep-screen";
  };
in
{
  home.packages = [ sleepScreen ];
}
