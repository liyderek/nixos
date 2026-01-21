{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "iloader";
  version = "1.1.6";

  src = pkgs.fetchurl {
    url = "https://github.com/nab138/iloader/releases/download/v1.1.6/iloader-linux-amd64.deb";
    sha256 = "1islnpkih3rjb8c4jkkij1cvpqnsvssjhsjb34awfqgbb9phkpi5";
  };

  nativeBuildInputs = [
    pkgs.dpkg
    pkgs.makeWrapper
  ];

  buildInputs = with pkgs; [
    gtk3
    gdk-pixbuf
    glib
    cairo
    pango
    webkitgtk_4_1
    libayatana-appindicator
    openssl
    libsoup_3
    usbmuxd
  ];

  unpackPhase = "dpkg-deb -x $src $out";

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/applications
    mkdir -p $out/share/icons/hicolor/256x256/apps

    makeWrapper $out/usr/bin/iloader $out/bin/iloader \
      --prefix LD_LIBRARY_PATH : ${
        pkgs.lib.makeLibraryPath [
          pkgs.gtk3
          pkgs.gdk-pixbuf
          pkgs.glib
          pkgs.cairo
          pkgs.pango
          pkgs.webkitgtk_4_1
          pkgs.libayatana-appindicator
          pkgs.openssl
          pkgs.libsoup_3
          pkgs.usbmuxd
        ]
      }

    cat > $out/share/applications/iloader.desktop <<EOF
      [Desktop Entry]
      Name=iLoader
      Comment=iOS sideloading utility
      Exec=iloader
      Icon=iloader
      Terminal=false
      Type=Application
      Categories=Utility;
      EOF

    if [ -f $out/usr/share/icons/hicolor/256x256/apps/iloader.png ]; then
      cp $out/usr/share/icons/hicolor/256x256/apps/iloader.png \
         $out/share/icons/hicolor/256x256/apps/iloader.png
    fi
  '';
}
