_: {
  flake.modules.nixos.apps =
    { customLib, pkgs, ... }:
    let
      packages = with pkgs; [
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
        hunspell
        hunspellDicts.en_US
        perf
        valgrind
        libxshmfence
        libvirt
        qemu_kvm
        swtpm
        virglrenderer
        cmake-lint
        arion
        bat
        podman
        podman-compose
        nil
        gst_all_1.gstreamer
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-good
        gst_all_1.gst-plugins-bad
        gst_all_1.gst-plugins-ugly
        gst_all_1.gst-libav
      ];
    in
    {
      environment.systemPackages = customLib.supportedPackages pkgs packages;
    };
}
