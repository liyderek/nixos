{ ... }:
{
  services.flatpak = {
    enable = true;
  };

  services.flatpak.remotes = [
    {
      name = "flathub";
      location = "https://flathub.org/repo/flathub.flatpakrepo";
    }
  ];

  services.flatpak.packages = [
    "gg.minion.Minion"
  ];
}
