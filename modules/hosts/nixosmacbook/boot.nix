_: {
  configurations.nixos.nixosmacbook.module =
    { lib, ... }:
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
          plymouth = {
            enable = true;
            showDelay = 0;
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

        catppuccin.plymouth = {
          enable = true;
          flavor = "mocha";
        };

        # Silence the Asahi stage before systemd-boot/Plymouth take over.
        nixpkgs.overlays = [
          (_final: prev: {
            uboot-asahi = prev.uboot-asahi.overrideAttrs (old: {
              postPatch = (old.postPatch or "") + ''
                substituteInPlace configs/apple_m1_defconfig \
                  --replace-fail 'CONFIG_BOOTDELAY=1' 'CONFIG_BOOTDELAY=0'
                cat >> configs/apple_m1_defconfig <<'EOF'
                CONFIG_SILENT_CONSOLE=y
                CONFIG_SILENT_CONSOLE_UNTIL_ENV=y
                CONFIG_SILENT_CONSOLE_UPDATE_ON_RELOC=y
                CONFIG_SILENT_U_BOOT_ONLY=y
                EOF
                printf '\nsilent=1\n' >> board/apple/mac/mac.env
              '';
              postConfigure = (old.postConfigure or "") + ''
                for option in SILENT_CONSOLE SILENT_CONSOLE_UNTIL_ENV \
                  SILENT_CONSOLE_UPDATE_ON_RELOC SILENT_U_BOOT_ONLY; do
                  grep -Fx "CONFIG_$option=y" .config
                done
                grep -Fx 'CONFIG_BOOTDELAY=0' .config
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
