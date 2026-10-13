_: {
  flake.modules.nixos.mongodb =
    { pkgs, ... }:
    {
      services.mongodb = {
        enable = true;
        package = pkgs.mongodb-ce;
      };
    };
}
