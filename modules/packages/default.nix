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
      };
    };
}
