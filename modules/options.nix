{ lib, ... }:
let
  configurations = lib.mkOption {
    type = lib.types.lazyAttrsOf (
      lib.types.submodule {
        options.module = lib.mkOption {
          type = lib.types.deferredModule;
          description = "Host configuration assembled from feature modules.";
        };
      }
    );
  };
in
{
  options.configurations = {
    nixos = configurations;
    homeManager = configurations;
  };
}
