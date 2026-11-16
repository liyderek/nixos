{
  description = "Shared NixOS desktop and Apple Silicon MacBook configuration";

  inputs = {
    self.lfs = true;
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    # VMware's NAT binary from this revision loads correctly; newer builds crash.
    nixpkgs-vmware.url = "github:nixos/nixpkgs/6510408d147d8c5e6d76043e899e9251756f6a75";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    nix-flatpak = {
      url = "github:gmodena/nix-flatpak";
    };

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    helix-plugins.url = "github:maxschipper/helix-plugins-nix";
    helix-plugins.inputs.nixpkgs.follows = "nixpkgs";

    nix-openclaw.url = "github:openclaw/nix-openclaw";

    nixos-apple-silicon = {
      url = "github:nix-community/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin-starship = {
      url = "github:catppuccin/starship";
      flake = false;
    };
    catppuccin.url = "github:catppuccin/nix";

    silent-sddm = {
      url = "github:uiriansan/SilentSDDM";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    apple-fonts.url = "github:Lyndeno/apple-fonts.nix";

    spicetify-nix.url = "github:gerg-l/spicetify-nix";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";

    compose2nix = {
      url = "github:aksiksi/compose2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-desktop.url = "github:k3d3/claude-desktop-linux-flake";
    claude-desktop.inputs.nixpkgs.follows = "nixpkgs";
    # claude-desktop.inputs.flake-utils.follows = "flake-utils";
  };

  outputs =
    inputs:
    let
      customLib = import ./lib { lib = inputs.nixpkgs.lib; };
    in
    inputs.flake-parts.lib.mkFlake
      {
        inherit inputs;
        specialArgs = { inherit customLib; };
      }
      {
        imports = [ (inputs.import-tree ./modules) ];
        flake.lib = customLib;
      };
}
