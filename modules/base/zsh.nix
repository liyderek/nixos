_: {
  flake.modules.homeManager.base =
    {
      lib,
      pkgs,
      host,
      ...
    }:
    {
      programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        oh-my-zsh = {
          enable = true;
          plugins = [
            "git"
            "fzf"
          ];
          theme = "agnoster";
        };
        initContent = lib.mkBefore ''
          DISABLE_MAGIC_FUNCTIONS=true
          export "MICRO_TRUECOLOR=1"
          export PATH="$HOME/.config/emacs/bin:$PATH"
        '';
        shellAliases = {
          # record = "wf-recorder --audio=alsa_output.pci-0000_08_00.6.analog-stereo.monitor -f $HOME/Videos/$(date +'%Y%m%d%H%M%S_1.mp4')";

          # Utils
          c = "clear";
          cd = "z";
          tt = "gtrash put";
          cat = "bat";
          nano = "micro";
          code = "codium";
          py = "python";
          icat = "kitten icat";
          dsize = "du -hs";
          findw = "grep -rl";
          pdf = "tdf";
          open = "xdg-open";
          nvim = "/etc/nixos/nix.sh run --refresh /home/derek/nvf-config#derek-neovim";
          java8 = "${pkgs.openjdk8}/bin/java";

          l = "eza --icons  -a --group-directories-first -1"; # EZA_ICON_SPACING=2
          ll = "eza --icons  -a --group-directories-first -1 --no-user --long";
          tree = "eza --icons --tree --group-directories-first";

          # Nixos
          cdnix = "/etc/nixos/nix.sh edit";
          ns = "/etc/nixos/nix.sh rebuild ${host}";
          ns1 = "/etc/nixos/nix.sh work ${host}";
          nsu = "/etc/nixos/nix.sh upgrade ${host}";
          nix-flake-update = "/etc/nixos/nix.sh update ${host}";
          nix-clean = "/etc/nixos/nix.sh clean";

          # Git
          ga = "git add";
          gaa = "git add --all";
          gs = "git status";
          gb = "git branch";
          gm = "git merge";
          gpl = "git pull";
          gplo = "git pull origin";
          gps = "git push";
          gpst = "git push --follow-tags";
          gpso = "git push origin";
          gc = "git commit";
          gcm = "git commit -m";
          gcma = "git add --all && git commit -m";
          gtag = "git tag -ma";
          gch = "git checkout";
          gchb = "git checkout -b";
          gcoe = "git config user.email";
          gcon = "git config user.name";

          # python
          piv = "python -m venv .venv";
          psv = "source .venv/bin/activate";
        };
      };

      programs.zoxide = {
        enable = true;
        enableZshIntegration = true;
      };
    };
}
