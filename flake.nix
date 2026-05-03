{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";

    nix-flatpak = {
      url = "github:gmodena/nix-flatpak";
    };

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hyprland = {
      url = "github:hyprwm/hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hypr-contrib.url = "github:hyprwm/contrib";

    catppuccin-starship = {
      url = "github:catppuccin/starship";
      flake = false;
    };
    catppuccin.url = "github:catppuccin/nix";

    apple-fonts.url = "github:Lyndeno/apple-fonts.nix";

    spicetify-nix.url = "github:gerg-l/spicetify-nix";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";

    compose2nix = {
      url = "github:aksiksi/compose2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-flake.url = "git+https://codeberg.org/catderek/neovim-flake.git";
    neovim-flake.inputs.nixpkgs.follows = "nixpkgs";

    jcode-nix.url = "github:hypervideo/jcode-nix";
    jcode-nix.inputs.nixpkgs.follows = "nixpkgs";
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
        nixos = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            {
              nixpkgs.overlays = [ inputs.jcode-nix.overlays.default ];
            }
            ./configuration.nix
            catppuccin.nixosModules.catppuccin
            home-manager.nixosModules.home-manager
            inputs.nix-flatpak.nixosModules.nix-flatpak
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
