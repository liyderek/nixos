_: {
  configurations.nixos.nixos.module = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      sunshine
      amf
      vmware-workstation
      seanime
      (callPackage ../../../packages/iloader.nix { })
    ];
  };
}
