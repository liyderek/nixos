{ inputs, ... }: {
  flake.modules.nixos.base = {
    imports = [ inputs.catppuccin.nixosModules.catppuccin ];
  };
}
