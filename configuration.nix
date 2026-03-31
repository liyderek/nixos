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
    (import ./system { inherit pkgs; })
    ./cachix.nix
  ];

  specialisation = {
    work.configuration = {
      home-manager.users.derek.my.desktopProfile = "work";
    };

    fun.configuration = {
      home-manager.users.derek.my.desktopProfile = "fun";
    };
  };
}
