{
  config,
  inputs,
  customLib,
  ...
}:
{
  flake.nixosConfigurations.nixos = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {
      inherit inputs customLib;
      host = "nixos";
    };
    modules = [ config.configurations.nixos.nixos.module ];
  };
}
