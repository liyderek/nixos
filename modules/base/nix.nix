_: {
  flake.modules.nixos.base = {
    # unfree
    nixpkgs.config.allowUnfree = true;

    # flakes
    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      builders-use-substitutes = true;
      trusted-users = [
        "root"
        "@wheel"
      ];
    };

    nixpkgs.config.permittedInsecurePackages = [
      "qtwebengine-5.15.19"
    ];
  };
}
