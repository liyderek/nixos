_: {
  flake.modules.nixos.base = {
    # unfree
    nixpkgs.config.allowUnfree = true;
    # GTK2 remains required by legacy packages; scope the exception to gtk+.
    nixpkgs.config.problems.handlers."gtk+".broken = "warn";

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
