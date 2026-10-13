_: {
  configurations.nixos.nixosmacbook.module =
    # Generated hardware configuration read from derek@nixosmacbook.
    # Put manual settings in config.nix or the Apple Silicon module.
    { lib, modulesPath, ... }: {
      imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

      boot.initrd.availableKernelModules = [ "usb_storage" ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ ];
      boot.extraModulePackages = [ ];

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/0835a743-7e1e-4505-8ef5-c7b606fa8506";
        fsType = "ext4";
      };

      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/E646-1B1F";
        fsType = "vfat";
        options = [
          "fmask=0022"
          "dmask=0022"
        ];
      };

      swapDevices = [ ];
      nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
    };
}
