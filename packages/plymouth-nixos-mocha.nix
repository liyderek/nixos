{
  lib,
  runCommand,
  writeText,
  imagemagick,
  nixos-icons,
  plymouth,
}:
let
  name = "nixos-mocha";
  descriptor = writeText "${name}.plymouth" (
    ''
      [Plymouth Theme]
      Name=NixOS Mocha
      Description=Minimal Mocha splash with a NixOS logo and progress bar
      ModuleName=two-step

      [two-step]
      Font=DejaVu Sans 12
      TitleFont=DejaVu Sans 12
      ImageDir=@THEME_DIR@
      HorizontalAlignment=0.5
      VerticalAlignment=0.5
      ProgressBarHorizontalAlignment=0.5
      ProgressBarVerticalAlignment=0.58
      ProgressBarWidth=240
      ProgressBarHeight=4
      ProgressBarBackgroundColor=0x45475a
      ProgressBarForegroundColor=0xcdd6f4
      BackgroundStartColor=0x1e1e2e
      BackgroundEndColor=0x1e1e2e
      ProgressFunction=linear
      Transition=none
      TransitionDuration=0
    ''
    +
      lib.concatMapStrings
        (mode: ''

          [${mode}]
          UseProgressBar=true
          ProgressBarShowPercentComplete=false
          UseAnimation=false
          UseEndAnimation=false
          UseFirmwareBackground=false
          SuppressMessages=true
        '')
        [
          "boot-up"
          "shutdown"
          "reboot"
          "updates"
          "system-upgrade"
          "firmware-upgrade"
          "system-reset"
        ]
  );
in
runCommand "plymouth-${name}"
  {
    nativeBuildInputs = [ imagemagick ];
    meta = {
      description = "Minimal NixOS logo and progress bar on a Catppuccin Mocha background";
      platforms = lib.platforms.linux;
    };
  }
  ''
    theme_dir="$out/share/plymouth/themes/${name}"
    mkdir -p "$theme_dir"
    cp ${descriptor} "$theme_dir/${name}.plymouth"
    substituteInPlace "$theme_dir/${name}.plymouth" \
      --replace-fail '@THEME_DIR@' "$theme_dir"

    magick ${nixos-icons}/share/icons/hicolor/256x256/apps/nix-snowflake-white.png \
      -resize 128x128 -channel RGB -fill '#cdd6f4' -colorize 100 +channel \
      "$theme_dir/header-image.png"

    # Required by two-step for password prompts; never shown during normal boot.
    for asset in lock entry bullet keyboard keymap-render capslock; do
      cp ${plymouth}/share/plymouth/themes/spinner/$asset.png "$theme_dir/"
    done
  ''
