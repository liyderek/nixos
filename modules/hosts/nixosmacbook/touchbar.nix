_: {
  configurations.nixos.nixosmacbook.module = { pkgs, ... }: {
    # Release the Touch Bar DRM device before the kernel suspends it. A restart
    # only after resume is too late once a framebuffer commit is stuck.
    powerManagement.powerDownCommands = ''
      ${pkgs.systemd}/bin/systemctl stop tiny-dfr.service
    '';
    powerManagement.resumeCommands = ''
      ${pkgs.systemd}/bin/systemctl --no-block start tiny-dfr.service
    '';
    # Keep retrying if the DRM device is not ready immediately after resume.
    systemd.services.tiny-dfr.unitConfig.StartLimitIntervalSec = 0;
    systemd.services.tiny-dfr.serviceConfig = {
      RestartSec = "5s";
      TimeoutStopSec = "5s";
    };
  };
}
