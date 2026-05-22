{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    wget
    git
    vim
    libgcc
    cmake
    gcc15
    chromium
    gparted
    ryubing # nintendo
    ripgrep
    ntfs3g
    exfatprogs
    gamemode
    sunshine
    amf
    libreoffice-qt
    hunspell
    hunspellDicts.en_US
    perf
    valgrind
    xorg.libxshmfence
    libvirt
    qemu_kvm
    swtpm
    virglrenderer
    vmware-workstation
    cmake-lint
    arion
    bat
    podman
    podman-compose
    nil
    jcode
    (callPackage ./iloader {})
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav
  ];
}
