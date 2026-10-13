_: {
  flake.modules.nixos.desktop = {
    specialisation = {
      work.configuration = {
        home-manager.users.derek.my.desktopProfile = "work";
      };
    };
  };
}
