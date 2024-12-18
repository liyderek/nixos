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
    catppuccin.url = "github:catppuccin/nix";

    apple-fonts.url = "github:Lyndeno/apple-fonts.nix";
  };

  outputs =
    inputs@{
      nixpkgs,
      catppuccin,
      home-manager,
      ...
    }:
    {
      nixosConfigurations = {
        dereknixos = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            ./configuration.nix
            catppuccin.nixosModules.catppuccin
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";

              home-manager.users.derek = import ./home;

              home-manager.extraSpecialArgs = {
                inherit
                  inputs
                  nixpkgs
                  catppuccin
                  ;
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
