_: {
  flake.modules.homeManager.apps = { pkgs, ... }: {
    programs.vscode = {
      enable = true;
      package = pkgs.vscode;
    };

    catppuccin.vscode.enable = false;
  };
}
