{ config, inputs, ... }:
let
  overlay = config.flake.overlays.default;
in
{
  perSystem =
    {
      pkgs,
      lib,
      system,
      ...
    }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ overlay ];
      };
      packages = {
        termsynicon = pkgs.callPackage ../../packages/termsynicon.nix { };
        chatgpt = pkgs.callPackage ../../packages/chatgpt.nix { };
        libinput-macos-trackpad = pkgs.callPackage ../../packages/libinput-macos-trackpad.nix { };
      }
      // lib.optionalAttrs pkgs.stdenv.hostPlatform.isx86_64 {
        iloader = pkgs.callPackage ../../packages/iloader.nix { };
        nimbalyst = pkgs.callPackage ../../packages/nimbalyst.nix { };
      };
    };
}
