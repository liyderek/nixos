_: {
  flake.modules.nixos.apps =
    { config, pkgs, ... }:
    let
      # Inference only: no training, HTTP server, or additional language tools.
      piper = pkgs.piper-tts.override {
        withAlignment = false;
        withHTTP = false;
        withJapanese = false;
        withTrain = false;
      };
      voiceUrl = "https://huggingface.co/rhasspy/piper-voices/resolve/e7229f7d33a10e145e109b886d661984201ac3c4/en/en_US/lessac/high";
      voice = pkgs.linkFarm "piper-lessac-high" [
        {
          name = "en_US-lessac-high.onnx";
          path = pkgs.fetchurl {
            url = "${voiceUrl}/en_US-lessac-high.onnx";
            hash = "sha256-TKv3w6Y4AXE380oVFlIgMtT+PzgiioQ8ybdk3cvNngk=";
          };
        }
        {
          name = "en_US-lessac-high.onnx.json";
          path = pkgs.fetchurl {
            url = "${voiceUrl}/en_US-lessac-high.onnx.json";
            hash = "sha256-20K5fZhZ8le8FWG47ZgOf7I5hAIFCnTd1svskxqSQS8=";
          };
        }
      ];
      speak = pkgs.writeShellApplication {
        name = "speechd-piper";
        runtimeInputs = [
          piper
          pkgs.python3
          pkgs.pulseaudio
        ];
        text = ''
          # Speech Dispatcher supplies rate and volume as percentages.
          read -r length_scale volume < <(
            python3 -c 'import sys; print(*(float(v) / 100 for v in sys.argv[1:]))' "$1" "$2"
          )
          piper --model ${voice}/en_US-lessac-high.onnx \
            --length-scale "$length_scale" --volume "$volume" \
            --sentence-silence 0.15 --output-raw \
            | paplay --raw --rate=22050 --format=s16le --channels=1 \
                --client-name="Piper TTS" --stream-name="Lessac High"
        '';
      };
      piperConfig = pkgs.writeText "piper.conf" ''
        GenericExecuteSynth "printf %s \'$DATA\' | ${speak}/bin/speechd-piper $RATE $VOLUME"
        GenericCmdDependency "${speak}/bin/speechd-piper"
        GenericDefaultCharset "utf-8"
        AddVoice "en" "FEMALE1" "lessac-high"
        AddVoice "en-us" "FEMALE1" "lessac-high"
        DefaultVoice "lessac-high"
        GenericRateAdd 100
        GenericRateMultiply -50
        GenericRateForceInteger 1
        GenericVolumeAdd 50
        GenericVolumeMultiply 50
        GenericVolumeForceInteger 1
      '';
    in
    {
      # Keep the stock configuration/modules while adding a neural default.
      services.speechd = {
        enable = true;
        package = pkgs.symlinkJoin {
          name = "${pkgs.speechd.name}-piper";
          paths = [ pkgs.speechd ];
          postBuild = ''
            rm "$out/etc/speech-dispatcher/speechd.conf"
            cat ${pkgs.speechd}/etc/speech-dispatcher/speechd.conf > "$out/etc/speech-dispatcher/speechd.conf"
            cat >> "$out/etc/speech-dispatcher/speechd.conf" <<'EOF'
            AddModule "piper" "sd_generic" "piper.conf"
            AddModule "espeak-ng" "sd_espeak-ng" "espeak-ng.conf"
            AddModule "pico" "sd_pico" "pico.conf"
            AddModule "flite" "sd_flite" "flite.conf"
            AddModule "espeak-ng-mbrola" "sd_espeak-ng-mbrola" "espeak-ng-mbrola.conf"
            DefaultModule "piper"
            DefaultLanguage "en-US"
            DefaultVoiceType "FEMALE1"
            EOF
            ln -s ${piperConfig} "$out/etc/speech-dispatcher/modules/piper.conf"
          '';
        };
      };
      systemd.user.services.speech-dispatcher.restartTriggers = [ config.services.speechd.package ];
    };

  flake.modules.homeManager.apps = { pkgs, ... }: {
    home.packages = [ pkgs.kdePackages.okular ];
  };
}
