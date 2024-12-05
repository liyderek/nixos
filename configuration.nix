# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    inputs.apple-silicon-support.nixosModules.apple-silicon-support
    (import ./system { inherit pkgs; })
  ];

  boot = {
    loader = {
      grub = {
        enable = true;
        useOSProber = true;
        copyKernels = true;
        efiInstallAsRemovable = true;
        efiSupport = true;
        fsIdentifier = "label";
        devices = [ "nodev" ];
        gfxmodeEfi = "2560x1600";
        # font = lib.mkForce "${pkgs.nerdfonts}/share/fonts/truetype/NerdFonts/JetBrainsMonoNerdFont-Regular.ttf";
        fontSize = 72;
        extraEntries = ''
          menuentry "Reboot" {
              reboot
          }
          menuentry "Poweroff" {
              halt
          }
        '';
        catppuccin.enable = true;
        extraConfig = ''
          GRUB_TIMEOUT_STYLE=hidden
        '';
      };
      timeout = 0;
    };
    plymouth = {
      enable = true;
      theme = "breeze";
      # themePackages = with pkgs; [
      #   # By default we would install all themes
      #   (adi1090x-plymouth-themes.override {
      #     selected_themes = [ "rings" ];
      #   })
      # ];
      extraConfig = ''
        ShowDelay=0
      '';
    };

    # Enable "Silent Boot"
    consoleLogLevel = 3;
    initrd = {
      verbose = false;
      # systemd.enable = true;
    };
    kernelParams = [
      "quiet"
      "loglevel=3"
      "udev.log-priority=3"
      "splash"
    ];
    # Hide the OS choice for bootloaders.
    # It's still possible to open the bootloader list by pressing any key
    # It will just not appear on screen unless a key is pressed
    # loader.timeout = 0;
  };
  # Use the systemd-boot EFI boot loader.
  # boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # unfree
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnsupportedSystem = true;

  # flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # asahi stuff
  hardware.asahi = {
    peripheralFirmwareDirectory = ./firmware;
    withRust = true;
    useExperimentalGPUDriver = true;
    experimentalGPUInstallMode = "replace";
    setupAsahiSound = true;
  };
  hardware.graphics.enable = true;

  # setup the displaylink
  services.xserver.videoDrivers = [
    "displaylink"
    "modesetting"
  ];

  # vpn
  services.cloudflare-warp = {
    enable = true;
  };

  # hyprland
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
  };

  networking.hostName = "dereknixos"; # Define your hostname.

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  services.xserver.enable = true;
  # services.xserver.displayManager.gdm = {
  #   enable = true;
  #   wayland = true;
  # };
  # services.xserver.displayManager.autoLogin = {
  #   enable = true;
  #   user = "derek";
  # };
  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${pkgs.hyprland}/bin/Hyprland";
        user = "derek";
      };
      default_session = initial_session;
    };
  };

  # set sudo stuff
  security.sudo.wheelNeedsPassword = false;

  # iwd
  networking.wireless.iwd = {
    enable = true;
    settings = {
      Network = {
        EnableIPv6 = true;
      };
      General = {
        Autoconnect = true;
        EnableNetworkConfiguration = true;
        AddressRandomization = "once";
        AddressRandomizationRange = "full";
      };
    };
  };

  networking.networkmanager.wifi.backend = "iwd";
  networking.networkmanager.insertNameservers = [
    "1.1.1.1"
    "8.8.8.8"
  ];
  networking.networkmanager.wifi.macAddress = "random";

  programs.zsh.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.derek = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
  };

  environment.systemPackages = with pkgs; [
    wget
    git
    vim
    libgcc
    cmake
    gcc14
    chromium
    gparted
    ryujinx # nintendo
    mkosi
  ];

  system.stateVersion = "24.11"; # dont change

}
