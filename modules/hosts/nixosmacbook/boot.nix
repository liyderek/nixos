_: {
  configurations.nixos.nixosmacbook.module =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      theme = pkgs.callPackage ../../../packages/plymouth-nixos-mocha.nix {
        plymouth = config.boot.plymouth.package;
      };
    in
    {
      # Asahi adds earlycon; filter it out without dropping its other parameters.
      options.boot.kernelParams = lib.mkOption {
        apply = lib.filter (param: param != "earlycon" && !(lib.hasPrefix "earlycon=" param));
      };

      config = {
        boot = {
          loader.timeout = 0;
          consoleLogLevel = 0;
          initrd.verbose = false;
          initrd.systemd = {
            settings.Manager = {
              DefaultStandardOutput = "journal";
              DefaultStandardError = "journal";
              ShowStatus = false;
            };
            services.initrd-nixos-activation.serviceConfig = {
              StandardOutput = "journal";
              StandardError = "journal";
            };
          };
          plymouth = {
            enable = true;
            showDelay = 0;
            theme = "nixos-mocha";
            themePackages = [ theme ];
          };
          kernelParams = [
            "quiet"
            "systemd.show_status=false"
            "rd.systemd.show_status=false"
            "systemd.log_target=journal"
            "rd.systemd.log_target=journal"
            "udev.log_level=3"
            "rd.udev.log_level=3"
            "vt.global_cursor_default=0"
          ];
        };

        catppuccin.plymouth.enable = false;

        systemd.settings.Manager = {
          DefaultStandardOutput = "journal";
          DefaultStandardError = "journal";
          ShowStatus = false;
        };
        # Keep the final splash frame while the graphical session takes over.
        systemd.services.plymouth-quit.serviceConfig.ExecStart = [
          ""
          "${config.boot.plymouth.package}/bin/plymouth quit --retain-splash"
        ];

        # Silence the Asahi stage before systemd-boot/Plymouth take over.
        nixpkgs.overlays = [
          (_final: prev: {
            uboot-asahi = prev.uboot-asahi.overrideAttrs (old: {
              patches = (old.patches or [ ]) ++ [ ../../../packages/uboot-silent-file-console.patch ];
              postPatch = (old.postPatch or "") + ''
                substituteInPlace configs/apple_m1_defconfig \
                  --replace-fail 'CONFIG_BOOTDELAY=1' 'CONFIG_BOOTDELAY=0'
                cat >> configs/apple_m1_defconfig <<'EOF'
                CONFIG_SILENT_CONSOLE=y
                CONFIG_SILENT_CONSOLE_UNTIL_ENV=y
                CONFIG_SILENT_CONSOLE_UPDATE_ON_RELOC=y
                CONFIG_SILENT_U_BOOT_ONLY=y
                CONFIG_SYS_CONSOLE_INFO_QUIET=y
                CONFIG_VIDEO_LOGO=n
                CONFIG_DISPLAY_BOARDINFO=n
                CONFIG_DISPLAY_BOARDINFO_LATE=n
                EOF
                printf '\nsilent=1\n' >> board/apple/mac/mac.env
              '';
              postConfigure = (old.postConfigure or "") + ''
                for option in SILENT_CONSOLE SILENT_CONSOLE_UNTIL_ENV \
                  SILENT_CONSOLE_UPDATE_ON_RELOC SILENT_U_BOOT_ONLY \
                  SYS_CONSOLE_INFO_QUIET; do
                  grep -Fx "CONFIG_$option=y" .config
                done
                grep -Fx 'CONFIG_BOOTDELAY=0' .config
                grep -Fx '# CONFIG_VIDEO_LOGO is not set' .config
                grep -Fx '# CONFIG_DISPLAY_BOARDINFO is not set' .config
                grep -Fx '# CONFIG_DISPLAY_BOARDINFO_LATE is not set' .config
              '';
              postBuild = (old.postBuild or "") + ''
                strings u-boot-nodtb.bin | grep -Fx 'silent=1'
              '';
            });
          })
        ];
      };
    };
}
