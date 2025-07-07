{ pkgs, ... }:
{
  virtualisation.oci-containers.containers.librechat = {
    image = "ghcr.io/danny-avila/librechat:v0.7.8";
    ports = [ "3080:3080" ]; # Access LibreChat at http://localhost:3080
    environment = {
      HOST = "0.0.0.0";
      MONGO_URI = "mongodb://localhost:27017/LibreChat";
    };
    environmentFiles = [
      "/etc/librechat.env"
    ];
  };

  virtualisation.oci-containers.backend = "podman"; # or docker
}
