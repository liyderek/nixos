{
  lib,
  stdenv,
  buildFHSEnv,
  dpkg,
}:
let
  version = "26.930.21537";

  chatgpt-unwrapped = stdenv.mkDerivation {
    pname = "chatgpt-unwrapped";
    inherit version;

    src = ../assets/deb/chatgpt_amd64.deb;

    nativeBuildInputs = [ dpkg ];

    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;
    dontPatchELF = true;
    dontStrip = true;

    installPhase = ''
      runHook preInstall
      dpkg-deb -x "$src" "$out"
      runHook postInstall
    '';
  };
in
buildFHSEnv {
  pname = "chatgpt";
  inherit version;

  targetPkgs =
    pkgs: with pkgs; [
      alsa-lib
      at-spi2-core
      cairo
      cups
      dbus
      expat
      gdk-pixbuf
      glib
      gtk3
      libdrm
      libgbm
      libglvnd
      libnotify
      libusb1
      libxkbcommon
      mesa
      nspr
      nss
      openssl
      pango
      systemd
      tpm2-tss
      vulkan-loader
      xdg-utils
      libx11
      libxcomposite
      libxdamage
      libxext
      libxfixes
      libxrandr
      libxcb
    ];

  runScript = "${chatgpt-unwrapped}/usr/bin/chatgpt";

  extraInstallCommands = ''
    install -Dm644 ${chatgpt-unwrapped}/usr/share/applications/chatgpt.desktop \
      "$out/share/applications/chatgpt.desktop"
    install -Dm644 ${chatgpt-unwrapped}/usr/share/pixmaps/chatgpt.png \
      "$out/share/pixmaps/chatgpt.png"
    install -Dm644 ${chatgpt-unwrapped}/usr/share/metainfo/com.openai.chatgpt.metainfo.xml \
      "$out/share/metainfo/com.openai.chatgpt.metainfo.xml"
  '';

  meta = {
    description = "ChatGPT desktop application by OpenAI";
    homepage = "https://openai.com/chatgpt/desktop/";
    license = lib.licenses.unfree;
    mainProgram = "chatgpt";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
