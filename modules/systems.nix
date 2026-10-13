{ ... }: {
  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];
  perSystem = { pkgs, ... }: {
    formatter = pkgs.nixfmt;
    devShells.default = pkgs.mkShellNoCC {
      packages = [
        pkgs.just
        pkgs.nh
        pkgs.git-lfs
        pkgs.nixfmt
      ];
    };
  };
}
