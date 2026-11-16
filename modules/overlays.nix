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
    # Correct the opencode 2.2.5 Bun dependency hash in nixpkgs.
    opencode = prev.opencode.overrideAttrs (old: {
      node_modules = old.node_modules.overrideAttrs (_: {
        outputHash = "sha256-prx9dX7kUvs/E3zopkaPk5LXh3xJAy5sZeum/W8L7cA=";
      });
    });
  };
  flake.modules.nixos.base.nixpkgs.overlays = [ config.flake.overlays.default ];
}
