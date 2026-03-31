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
      services.greetd.settings = {
        initial_session = {
          command = lib.mkForce "${pkgs.sway}/bin/sway";
          user = "derek";
        };
        default_session = {
          command = lib.mkForce "${pkgs.sway}/bin/sway";
          user = "derek";
        };
      };
    };

    fun.configuration = {
      home-manager.users.derek.my.desktopProfile = "fun";
      services.greetd.settings = {
        initial_session = {
          command = lib.mkForce "${pkgs.hyprland}/bin/Hyprland";
          user = "derek";
        };
        default_session = {
          command = lib.mkForce "${pkgs.hyprland}/bin/Hyprland";
          user = "derek";
        };
      };
    };
  };
}
