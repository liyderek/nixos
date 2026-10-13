{
  config,
  inputs,
  customLib,
  ...
}:
{
  flake.nixosConfigurations.nixosmacbook = inputs.nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";
    specialArgs = {
      inherit inputs customLib;
      host = "nixosmacbook";
    };
    modules = [ config.configurations.nixos.nixosmacbook.module ];
  };
}
