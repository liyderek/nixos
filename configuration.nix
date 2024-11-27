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

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

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
  services.xserver.displayManager.gdm = {
    enable = true;
    wayland = true;
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
    codespell
    conan
    cppcheck
    doxygen
    gtest
    lcov
    vcpkg
    vcpkg-tool
    gcc14
    chromium
    kanshi
    gparted
    ryujinx # nintendo
  ];

  system.stateVersion = "24.11"; # dont change

}
