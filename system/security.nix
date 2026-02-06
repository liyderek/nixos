{ pkgs, ... }:
{
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
  };
}
