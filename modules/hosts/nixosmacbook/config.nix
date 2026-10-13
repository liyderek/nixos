_: {
  configurations.nixos.nixosmacbook.module = { lib, ... }: {
    networking.hostName = "nixosmacbook";
    networking.networkmanager.wifi.backend = "iwd";
    networking.firewall.enable = lib.mkForce true;

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = false;

    hardware.bluetooth.enable = true;
    services.blueman.enable = true;
    services.libinput.enable = true;
    services.power-profiles-daemon.enable = true;
    services.upower.enable = true;

    swapDevices = [
      {
        device = "/swapfile";
        size = 8 * 1024;
      }
    ];
    nix.settings = {
      max-jobs = 1;
      cores = 2;
      max-substitution-jobs = 4;
      http-connections = 4;
    };

    # Preserve the original install's compatibility settings.
    system.stateVersion = "26.11";
  };
}
