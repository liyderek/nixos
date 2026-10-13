{ inputs, ... }: {
  flake.modules.nixos.apps =
    { ... }:
    {
      imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];
      services.flatpak = {
        enable = true;
      };

      services.flatpak.remotes = [
        {
          name = "flathub";
          location = "https://flathub.org/repo/flathub.flatpakrepo";
        }
      ];

    };
}
