{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    apple-silicon-support = {
      url = "github:oliverbestmann/nixos-apple-silicon";
    };

    hyprland = {
      url = "github:hyprwm/hyprland";
    };
    hypr-contrib.url = "github:hyprwm/contrib";

    catppuccin-starship = {
      url = "github:catppuccin/starship";
      flake = false;
    };
  };

  outputs =
    inputs@{ nixpkgs, home-manager, ... }:
    {
      nixosConfigurations = {
        dereknixos = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            ./configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";

              home-manager.users.derek = import ./home;

              home-manager.extraSpecialArgs = {
                inherit inputs nixpkgs;
              };
            }
          ];
          specialArgs = {
            inherit inputs nixpkgs;
          };
        };
      };
    };
}
