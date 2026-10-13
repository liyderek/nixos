_: {
  flake.modules.homeManager.desktop = { pkgs, ... }: {
    catppuccin = {
      enable = true;
      accent = "pink";
    };
  };
}
