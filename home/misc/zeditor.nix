{ pkgs, ... }:
{
  programs.zed-editor = {
    enable = true;
    # extensions = [
    #   "nix"
    #   "toml"
    #   "elixir"
    #   "make"
    # ];
  };
}
