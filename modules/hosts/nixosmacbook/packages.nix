_: {
  configurations.nixos.nixosmacbook.module = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      brightnessctl
    ];
  };
}
