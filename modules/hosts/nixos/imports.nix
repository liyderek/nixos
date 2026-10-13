{ config, ... }: {
  configurations.nixos.nixos.module = {
    imports = with config.flake.modules.nixos; [
      apps
      base
      containers
      desktop
      services
      home-manager
      mongodb
      sunshine
    ];
  };
  configurations.homeManager.nixos.module = {
    imports = with config.flake.modules.homeManager; [
      apps
      base
      desktop
      dev
    ];
  };
}
