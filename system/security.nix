{pkgs, ...}: {
  security = {
    rtkit.enable = true;

    # set sudo stuff
    sudo.wheelNeedsPassword = false;

    wrappers.sunshine = {
      owner = "root";
      group = "root";
      capabilities = "cap_sys_admin+p";
      source = "${pkgs.sunshine}/bin/sunshine";
    };

    pki.certificateFiles = [
      # Replace this with the EXACT path from Step 1!
      # Note: You MUST use the absolute path (/home/...) do not use a tilde (~)
      ./rootCA.pem
    ];
  };
}
