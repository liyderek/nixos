{ config, ... }: {
  configurations.nixos.nixosmacbook.module = {
    imports = with config.flake.modules.nixos; [
      apps
      base
      containers
      desktop
      services
      home-manager
      apple-silicon
      joycond
    ];
  };
  configurations.homeManager.nixosmacbook.module = {
    imports = with config.flake.modules.homeManager; [
      apps
      base
      desktop
      dev
    ];
  };
}
