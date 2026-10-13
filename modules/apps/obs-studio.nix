_: {
  flake.modules.homeManager.apps = { pkgs, ... }: {
    programs.obs-studio = {
      enable = true;
      plugins = [ pkgs.obs-studio-plugins.wlrobs ];
    };
  };
}
