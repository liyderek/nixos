{
  config,
  inputs,
  customLib,
  ...
}:
let
  homes = config.configurations.homeManager;
in
{
  flake.modules.nixos.home-manager = { config, ... }: {
    imports = [ inputs.home-manager.nixosModules.home-manager ];
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
      users.derek = homes.${config.networking.hostName}.module;
      extraSpecialArgs = {
        inherit inputs customLib;
        host = config.networking.hostName;
        catppuccin = inputs.catppuccin;
      };
    };
  };
}
