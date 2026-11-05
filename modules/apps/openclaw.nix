{ inputs, ... }: {
  flake.modules.nixos.apps.nixpkgs.overlays = [
    (
      final: prev:
      let
        # Extend the upstream binary Node fallback with its matching Linux ARM64
        # archive. Keep this runtime private to OpenClaw's package set.
        isLinuxArm = prev.stdenv.hostPlatform.isLinux && prev.stdenv.hostPlatform.isAarch64;
        needsArmRuntime = isLinuxArm && prev.lib.versionOlder prev.nodejs_24.version "24.22.1";
        armNode =
          (prev.callPackage (inputs.nix-openclaw + "/nix/packages/nodejs-24.nix") { }).overrideAttrs
            (old: {
              src = prev.fetchurl {
                url = "https://nodejs.org/dist/v24.22.1/node-v24.22.1-linux-arm64.tar.xz";
                hash = "sha256-26v3ocv5R+YFn/rSwnuABB25feoeVTtir97n8T/KM24=";
              };
              meta = old.meta // {
                platforms = [ "aarch64-linux" ];
              };
            });
        openclawPkgs = prev // {
          nodejs_24 = if needsArmRuntime then armNode else prev.nodejs_24;
        };
        upstream = inputs.nix-openclaw.overlays.default final openclawPkgs;
      in
      upstream
      // {
        # The batteries bundle includes a pnpm executable without a Linux ARM64
        # pin. The gateway component still supplies the CLI, TUI, and web UI;
        # Home Manager adds the platform's runtime tools to its service PATH.
        openclaw = if isLinuxArm then upstream.openclaw-gateway else upstream.openclaw;
        openclawRuntimePlugins = upstream.openclawRuntimePlugins // {
          discord = final.callPackage ../../packages/openclaw-discord-personal-jarvis.nix {
            discord = upstream.openclawRuntimePlugins.discord;
            nodejs = upstream.openclawPackages.nodejs_24;
          };
        };
        openclawPackages = upstream.openclawPackages // {
          withTools =
            args:
            let
              packages = upstream.openclawPackages.withTools args;
            in
            packages
            // {
              openclaw = if isLinuxArm then upstream.openclaw-gateway else packages.openclaw;
            };
        };
      }
    )
  ];

  flake.modules.nixos.apps.services.tailscale = {
    enable = true;
    extraSetFlags = [ "--operator=derek" ];
  };

  flake.modules.nixos.apps.services.ollama = {
    enable = true;
    loadModels = [ "qwen3-embedding:0.6b" ];
  };

  flake.modules.homeManager.apps =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      stateDir = "${config.home.homeDirectory}/.openclaw";
      tokenFile = "${stateDir}/gateway-token";
    in
    {
      imports = [ inputs.nix-openclaw.homeManagerModules.openclaw ];

      programs.openclaw = {
        enable = true;
        inherit stateDir;
        runtimePackages = [ pkgs.tailscale ];

        workspace.bootstrapFiles = {
          agents = pkgs.writeText "openclaw-AGENTS.md" ''
            # Operating context

            You assist Derek on NixOS. Use the project's own instructions when
            working in a repository. Projects may live anywhere in Derek's home
            directory, including /home/derek/Documents/scrape_new.

            Use absolute paths when working outside this agent's workspace.
            Inspect the relevant files, make focused changes, and verify results.
          '';
          soul = pkgs.writeText "openclaw-SOUL.md" ''
            Be concise, practical, and direct. Lead with the answer or result.
            Use short explanations and include technical detail when it helps.
            Match the depth of your response to the task and the user's request.
            Avoid filler, repetition, and unnecessary narration of tool calls.
            Report what changed and what you verified; state uncertainty plainly.
          '';
          tools = pkgs.writeText "openclaw-TOOLS.md" ''
            # Local tools

            Commands run locally as Derek. Software and system configuration are
            managed with Nix and Home Manager in /etc/nixos.

            Read INTEGRATIONS.md for configured accounts, browser profiles,
            the Obsidian vault path, and available integration tools.
          '';
          identity = pkgs.writeText "openclaw-IDENTITY.md" ''
            # Identity

            - Name: Claw
            - Role: Derek's practical technical assistant
          '';
          user = pkgs.writeText "openclaw-USER.md" ''
            # User

            - Name: Derek
            - Platforms: NixOS desktop and Apple Silicon MacBook
            - Preferences: concise, practical answers and declarative configuration
          '';
        };

        config = {
          gateway = {
            mode = "local";
            bind = "loopback";
            controlUi.enabled = true;
            tailscale.mode = "serve";
            auth = {
              mode = "token";
              allowTailscale = true;
              token = {
                source = "file";
                provider = "gateway-token";
                id = "value";
              };
            };
          };
          secrets.providers.gateway-token = {
            source = "file";
            path = tokenFile;
            mode = "singleValue";
          };
          memory.search = {
            provider = "ollama";
            model = "qwen3-embedding:0.6b";
          };
          agents.defaults = {
            model.primary = "openai/gpt-6-sol";
            models."openai/gpt-6-sol".agentRuntime.id = "openclaw";
            thinkingDefault = "high";
            sandbox.mode = "off";
          };
          tools = {
            profile = "full";
            exec.host = "gateway";
            fs.workspaceOnly = false;
          };
        };
      };

      home.sessionVariables = {
        OPENCLAW_NIX_MODE = "1";
        OPENCLAW_STATE_DIR = stateDir;
        OPENCLAW_CONFIG_PATH = "${stateDir}/openclaw.json";
      };

      home.activation.openclawGatewayToken =
        lib.hm.dag.entryBetween [ "reloadSystemd" ] [ "openclawDirs" ]
          ''
            run ${pkgs.coreutils}/bin/chmod 0700 ${lib.escapeShellArg stateDir}
            if [ ! -s ${lib.escapeShellArg tokenFile} ]; then
              run ${pkgs.coreutils}/bin/install -m 0600 /dev/null ${lib.escapeShellArg tokenFile}
              run ${pkgs.openssl}/bin/openssl rand -hex -out ${lib.escapeShellArg tokenFile} 32
            fi
            run ${pkgs.coreutils}/bin/chmod 0600 ${lib.escapeShellArg tokenFile}
          '';

      systemd.user.services.openclaw-gateway.Install.WantedBy = [ "default.target" ];
    };
}
