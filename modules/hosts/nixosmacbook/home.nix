_: {
  configurations.homeManager.nixosmacbook.module = { pkgs, ... }: {
    home.packages = [ pkgs.ollama ];
    home.stateVersion = "26.11";
  };
}
