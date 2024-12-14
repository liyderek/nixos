{ pkgs, ... }:
{
  programs.helix = {
    enable = true;

    languages.language = [
      {
        name = "nix";
        auto-format = true;
        formatter.command = "${pkgs.nixfmt}/bin/nixfmt";
      }
    ];
  };

  home.packages = with pkgs; [ helix ];
}
