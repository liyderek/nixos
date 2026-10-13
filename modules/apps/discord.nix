_: {
  flake.modules.homeManager.apps =
    { lib, pkgs, ... }:
    {
      home.packages =
        with pkgs;
        lib.optionals (lib.meta.availableOn stdenv.hostPlatform discord) [
          # discord
          (discord.override {
            withVencord = true;
          })
        ];
    };
}
