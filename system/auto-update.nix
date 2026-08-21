{ pkgs, ... }:
let
  notifyScript = pkgs.writeShellScript "nixos-update-notify-error" ''
    ${pkgs.util-linux}/bin/runuser -u derek -- \
      env \
        DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus" \
        XDG_RUNTIME_DIR="/run/user/1000" \
      ${pkgs.libnotify}/bin/notify-send \
        --urgency=critical \
        --app-name="NixOS Auto-Update" \
        "NixOS Auto-Update Failed" \
        "The 2 AM flake update or rebuild failed. Check: journalctl -u nixos-auto-update"
  '';

  updateScript = pkgs.writeShellScript "nixos-auto-update" ''
    set -euo pipefail
    cd /etc/nixos
    ${pkgs.nix}/bin/nix flake update
    ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake /etc/nixos
  '';
in
{
  systemd.services.nixos-auto-update = {
    description = "NixOS flake auto-update and rebuild";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    unitConfig.OnFailure = "nixos-auto-update-notify.service";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = updateScript;
    };
  };

  systemd.services.nixos-auto-update-notify = {
    description = "NixOS update failure notification";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = notifyScript;
    };
  };

  systemd.timers.nixos-auto-update = {
    description = "NixOS flake auto-update timer";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 02:00:00";
      Persistent = true;
    };
  };
}
