_: {
  configurations.homeManager.nixosmacbook.module =
    { lib, pkgs, ... }:
    let
      vesktop = pkgs.vesktop.override { withSystemVencord = true; };
    in
    {
      home.packages = [
        pkgs.ollama
        vesktop
        # Keep the Discord shortcuts working with the ARM-native client.
        (pkgs.writeShellScriptBin "discord" ''
          exec ${lib.getExe vesktop} "$@"
        '')
      ];
      home.stateVersion = "26.11";

      my.niri.animations.enable = true;
      # Physical Command is Ctrl after the Apple keyboard modifier swap.
      my.niri.extraBinds = ''
        Ctrl+Shift+4 repeat=false { spawn "screenshot" "copy"; }
      '';
      # The built-in trackpad's custom motion/scroll curves are loaded by input.nix.
      my.niri.pointerSettings = ''
        mouse {
          natural-scroll
          accel-speed 0.2
          accel-profile "adaptive"
          scroll-factor 0.5
        }
        touchpad {
          natural-scroll
          accel-speed 0.0
          accel-profile "adaptive"
          scroll-factor 0.25
        }
      '';

      programs.alacritty.settings.font = {
        normal.family = lib.mkForce "Maple Mono NF";
        bold.family = lib.mkForce "Maple Mono NF";
        italic.family = lib.mkForce "Maple Mono NF";
        bold_italic.family = lib.mkForce "Maple Mono NF";
        size = lib.mkForce 10;
      };
    };
}
