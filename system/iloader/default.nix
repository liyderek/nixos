{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "iloader";
  version = "1.1.6";

  src = pkgs.fetchurl {
    url = "https://github.com/nab138/iloader/releases/download/v1.1.6/iloader-linux-amd64.deb";
    sha256 = "sha256-1islnpkih3rjb8c4jkkij1cvpqnsvssjhsjb34awfqgbb9phkpi5=";
  };

  nativeBuildInputs = [ pkgs.dpkg ];

  unpackPhase = "dpkg-deb -x $src $out";

  installPhase = ''
    mkdir -p $out/bin
    ln -s $out/usr/bin/iloader $out/bin/iloader
  '';
}
