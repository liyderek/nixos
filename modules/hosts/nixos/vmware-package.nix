{ inputs, ... }: {
  configurations.nixos.nixos.module.nixpkgs.overlays = [
    (_: _: {
      # Keep VMware on the last known-good Nixpkgs pin: newer vmnet-natd
      # crashes in the dynamic loader when the NAT service starts.
      vmware-workstation =
        (import inputs.nixpkgs-vmware {
          system = "x86_64-linux";
          config.allowUnfree = true;
        }).vmware-workstation;
    })
  ];
}
