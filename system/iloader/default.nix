{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "iloader";
  version = "git";

  src = pkgs.fetchFromGitHub {
    owner = "nab138";
    repo = "iloader";
    rev = "main";
    sha256 = "REPLACE_WITH_REAL_SHA256";
  };

  nativeBuildInputs = with pkgs; [
    nodejs
    pnpm
    rustc
    cargo
    pkg-config
  ];

  buildInputs = with pkgs; [
    webkitgtk
    gtk3
    libayatana-appindicator
    openssl
  ];

  buildPhase = ''
    export HOME=$TMPDIR
    pnpm install
    pnpm run build
    pnpm run tauri build
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp src-tauri/target/release/iloader $out/bin/
  '';
}
