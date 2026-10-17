_: {
  configurations.nixos.nixosmacbook.module = { lib, ... }: {
    networking.hostName = "nixosmacbook";
    networking.networkmanager.wifi.backend = "iwd";
    networking.firewall.enable = lib.mkForce true;

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = false;

    # Swap Command (Super) and Control on the Apple keyboard.
    boot.extraModprobeConfig = ''
      options hid_apple swap_ctrl_cmd=1
    '';

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

    # Prefer compressed RAM swap before the SSD swap file.
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 100;
      priority = 100;
    };
    boot.kernel.sysctl = {
      "vm.swappiness" = 150;
      "vm.page-cluster" = 0;
    };

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
