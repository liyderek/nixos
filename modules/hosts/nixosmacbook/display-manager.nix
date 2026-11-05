{ inputs, ... }: {
  configurations.nixos.nixosmacbook.module =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      pointerCursor = config.home-manager.users.derek.home.pointerCursor;
      cursorTheme = pointerCursor.name;
      cursorSize = 36;
      # Qt/Wayland can request "default" even with XCURSOR_THEME set. A path
      # containing only the named theme leaves those cursor lookups empty.
      cursorIcons = pkgs.runCommand "sddm-cursor-icons" { } ''
        mkdir -p "$out/share/icons"
        ln -s ${pointerCursor.package}/share/icons/${cursorTheme} "$out/share/icons/${cursorTheme}"
        ln -s ${cursorTheme} "$out/share/icons/default"
        test -r "$out/share/icons/default/cursors/left_ptr"
      '';
      cursorPath = "${cursorIcons}/share/icons";
      # Resolve the persistent alias at startup instead of hard-coding a card number.
      greeterCompositor = pkgs.writeShellScript "sddm-weston-asahi" ''
        set -euo pipefail
        export XCURSOR_THEME=${cursorTheme}
        export XCURSOR_SIZE=${toString cursorSize}
        export XCURSOR_PATH=${cursorPath}
        display="$(${pkgs.coreutils}/bin/readlink -e /dev/dri/by-path/platform-soc:display-subsystem-card)"
        card="$(${pkgs.coreutils}/bin/basename "$display")"
        exec ${config.services.displayManager.sddm.wayland.compositorCommand} \
          --drm-device="$card" "$@"
      '';
    in
    {
      imports = [ inputs.silent-sddm.nixosModules.default ];

      services.greetd.enable = lib.mkForce false;
      services.displayManager = {
        defaultSession = "niri";
        autoLogin.enable = false;
        sddm.settings = {
          Wayland.CompositorCommand = toString greeterCompositor;
          Theme = {
            CursorTheme = cursorTheme;
            CursorSize = cursorSize;
          };
          # The greeter is launched separately from Weston, so configure it too.
          General.GreeterEnvironment = lib.mkForce (
            lib.concatStringsSep "," [
              "QML2_IMPORT_PATH=${config.programs.silentSDDM.package'}/share/sddm/themes/silent/components/"
              "QT_IM_MODULE=qtvirtualkeyboard"
              "QT_SCALE_FACTOR=1.5"
              "QT_SCALE_FACTOR_ROUNDING_POLICY=PassThrough"
              "XCURSOR_THEME=${cursorTheme}"
              "XCURSOR_SIZE=${toString cursorSize}"
              "XCURSOR_PATH=${cursorPath}"
            ]
          );
        };
      };

      programs.silentSDDM = {
        enable = true;
        theme = "default";
        wayland = {
          enable = true;
          compositor = "weston";
        };
        backgrounds.galaxies = ../../../assets/wallpaper/kurzgesagt-galaxies.webp;
        settings = {
          LockScreen.background = "kurzgesagt-galaxies.webp";
          LoginScreen.background = "kurzgesagt-galaxies.webp";
        };
      };

      # Keep greeter output in the journal during the Plymouth handoff.
      systemd.services.display-manager.serviceConfig = {
        StandardOutput = "journal";
        StandardError = "journal";
      };
    };
}
