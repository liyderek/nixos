_: {
  configurations.nixos.nixosmacbook.module =
    { config, pkgs, ... }:
    {
      # Power-supply notifications alone do not issue the hard wake needed to
      # leave Asahi's s2idle. Build the bridge for each specialisation's kernel.
      boot.extraModulePackages = [
        (pkgs.callPackage ../../../packages/macsmc-ac-wake {
          kernel = config.boot.kernelPackages.kernel;
        })
      ];
      boot.kernelModules = [ "macsmc_ac_wake" ];

      services.logind.settings.Login = {
        HandleLidSwitch = "suspend";
        HandleLidSwitchExternalPower = "ignore";
        HandleLidSwitchDocked = "ignore";
      };

      services.udev.extraRules = ''
        SUBSYSTEM=="power_supply", KERNEL=="macsmc-ac", TEST=="power/wakeup", ATTR{power/wakeup}="enabled"
        ACTION=="change", SUBSYSTEM=="power_supply", KERNEL=="macsmc-ac", IMPORT{db}="MACBOOK_AC_ONLINE"
        ACTION=="change", SUBSYSTEM=="power_supply", KERNEL=="macsmc-ac", ATTR{online}=="1", ENV{MACBOOK_AC_ONLINE}!="1", RUN+="${pkgs.systemd}/bin/systemctl --no-block start macbook-ac-display-wake.service"
        SUBSYSTEM=="power_supply", KERNEL=="macsmc-ac", ATTR{online}=="1", ENV{MACBOOK_AC_ONLINE}="1"
        SUBSYSTEM=="power_supply", KERNEL=="macsmc-ac", ATTR{online}=="0", ENV{MACBOOK_AC_ONLINE}="0"
      '';

      systemd.services.macbook-ac-display-wake = {
        description = "Wake Niri monitors when AC power is connected";
        serviceConfig = {
          Type = "oneshot";
          User = "derek";
        };
        script = ''
          # NixOS allocates this user's UID dynamically; resolve it as the
          # service user instead of interpolating the nullable NixOS option.
          export XDG_RUNTIME_DIR="/run/user/$(id -u)"
          [ -S "$XDG_RUNTIME_DIR/bus" ] || exit 0

          # Niri includes its PID in the socket name, so discover the live
          # socket rather than baking in a session-specific path.
          for socket in "$XDG_RUNTIME_DIR"/niri.*.sock; do
            [ -S "$socket" ] || continue
            NIRI_SOCKET="$socket" ${pkgs.niri}/bin/niri msg action power-on-monitors
          done
        '';
      };

      powerManagement.resumeCommands = ''
        if [ "$(cat /sys/class/power_supply/macsmc-ac/online)" = 1 ]; then
          ${pkgs.systemd}/bin/systemctl --no-block start macbook-ac-display-wake.service
        fi
      '';
    };
}
