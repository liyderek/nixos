_: {
  flake.modules.homeManager.muvm =
    { pkgs, ... }:
    let
      muvm = pkgs.callPackage ../../packages/muvm.nix { };
    in
    {
      home.packages = with pkgs; [
        muvm
      ];
    };
}
