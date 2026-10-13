{ config, ... }: {
  flake.overlays.default = final: prev: {
    openldap = prev.openldap.overrideAttrs (_: {
      doCheck = false;
    });
  };
  flake.modules.nixos.base.nixpkgs.overlays = [ config.flake.overlays.default ];
}
