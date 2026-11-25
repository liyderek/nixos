{ inputs, ... }: {
  flake.modules.homeManager.apps =
    { lib, pkgs, ... }:
    let
      # The stable nixpkgs pin has an older Vencord incompatible with current Discord.
      vencord =
        (import inputs.nixpkgs-master {
          inherit (pkgs.stdenv.hostPlatform) system;
          inherit (pkgs) config;
        }).vencord;
    in
    {
      home.packages =
        with pkgs;
        lib.optionals (lib.meta.availableOn stdenv.hostPlatform discord) [
          # discord
          (discord.override {
            withVencord = true;
            inherit vencord;
          })
        ];
    };
}
