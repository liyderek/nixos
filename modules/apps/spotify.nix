_: {
  flake.modules.homeManager.apps =
    {
      pkgs,
      lib,
      inputs,
      ...
    }:
    let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      imports = [ inputs.spicetify-nix.homeManagerModules.default ];

      programs.spicetify = lib.mkIf (lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.spotify) {
        enable = true;
        enabledExtensions = with spicePkgs.extensions; [
          adblock
          hidePodcasts
          shuffle # shuffle+ (special characters are sanitized out of extension names)
        ];
        theme = spicePkgs.themes.onepunch;
      };
    };
}
