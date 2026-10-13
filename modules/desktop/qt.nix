_: {
  flake.modules.homeManager.desktop = { pkgs, ... }: {
    qt = {
      enable = true;
      platformTheme.name = "gtk";
      style.name = "kvantum";
    };
  };
}
