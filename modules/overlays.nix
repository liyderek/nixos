{ config, inputs, ... }: {
  flake.overlays.default = final: prev: {
    # Linux support from nixpkgs PR #551713 is available in the master input.
    chatgpt =
      (import inputs.nixpkgs-master {
        inherit (prev.stdenv.hostPlatform) system;
        inherit (prev) config;
      }).chatgpt;
    openldap = prev.openldap.overrideAttrs (_: {
      doCheck = false;
    });
  };
  flake.modules.nixos.base.nixpkgs.overlays = [ config.flake.overlays.default ];
}
