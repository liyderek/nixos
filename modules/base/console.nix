{ inputs, ... }: {
  flake.modules.nixos.base = { pkgs, ... }: {
    catppuccin = {
      enable = true;
      autoEnable = false;
      # Read the pinned JSON directly, without an architecture-specific palette build.
      sources.palette = (import inputs.catppuccin { inherit pkgs; }).packages.palette.src;
      tty = {
        enable = true;
        flavor = "mocha";
      };
    };

    console = {
      font = "ter-u32n";
      packages = [ pkgs.terminus_font ];
      earlySetup = true;
    };
  };
}
