_: {
  configurations.nixos.nixos.module = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      sunshine
      amf
      vmware-workstation
      (callPackage ../../../packages/iloader.nix { })
      (callPackage ../../../packages/chatgpt.nix { })
    ];
  };
}
