_: {
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    {
      # Credential/secret storage for compositor sessions.
      services.gnome.gnome-keyring.enable = true;

      programs.ssh.askPassword = pkgs.lib.mkForce "${pkgs.seahorse.out}/libexec/seahorse/ssh-askpass";
    };
}
