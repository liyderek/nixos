_: {
  flake.modules.homeManager.apps =
    {
      config,
      host,
      lib,
      pkgs,
      ...
    }:
    let
      secretDir = "${config.home.homeDirectory}/.config/openclaw/secrets";
      googleAccount = "derekli21870@gmail.com";
      googleKeyringPassword = "${secretDir}/google-keyring-password";
      vaultPath = "${config.home.homeDirectory}/Documents/Obsidian Vault";
      discordHost = host == "nixos";
      gog = pkgs.writeShellScriptBin "gog" ''
        set -euo pipefail
        export GOG_ACCOUNT=${lib.escapeShellArg googleAccount}
        export GOG_KEYRING_BACKEND=file
        export GOG_KEYRING_PASSWORD="$(${pkgs.coreutils}/bin/cat ${lib.escapeShellArg googleKeyringPassword})"
        exec ${lib.getExe pkgs.gogcli} "$@"
      '';
    in
    {
      programs.openclaw = {
        runtimePlugins = [ "brave" ] ++ lib.optional discordHost "discord";
        excludeTools = [ "gogcli" ];
        runtimePackages = [
          pkgs.gh
          gog
          pkgs.chromium
          pkgs.obsidian
        ];
        environment = {
          BRAVE_API_KEY = "${secretDir}/brave-api-key";
          GOG_ACCOUNT = googleAccount;
          GOG_KEYRING_BACKEND = "file";
          GOG_KEYRING_PASSWORD = googleKeyringPassword;
        }
        // lib.optionalAttrs discordHost {
          DISCORD_BOT_TOKEN = "${secretDir}/discord-bot-token";
        };

        config = {
          browser = {
            enabled = true;
            defaultProfile = "openclaw";
            executablePath = lib.getExe pkgs.chromium;
            headless = false;
            profiles.openclaw = {
              driver = "openclaw";
              cdpPort = 18800;
              headless = false;
            };
          };
          channels.discord = lib.mkIf discordHost {
            enabled = true;
            applicationId = "1566203251257245696";
            token = {
              source = "env";
              provider = "default";
              id = "DISCORD_BOT_TOKEN";
            };
            dmPolicy = "allowlist";
            allowFrom = [ "1353908629501247498" ];
            groupPolicy = "disabled";
            dm.groupEnabled = false;
            commands = {
              native = true;
              nativeSkills = true;
            };
            slashCommand.ephemeral = false;
            intents.messageContent = false;
          };
          commands = lib.mkIf discordHost {
            allowFrom.discord = [ "user:1353908629501247498" ];
            ownerAllowFrom = [ "discord:user:1353908629501247498" ];
          };
          plugins.entries = {
            browser.enabled = true;
            github.enabled = true;
          };
          tools.web = {
            search = {
              enabled = true;
              provider = "brave";
              maxResults = 5;
              timeoutSeconds = 30;
            };
            fetch.enabled = true;
          };
        };

        skills = [
          {
            name = "jarvis";
            description = "Ask Jarvis questions or request research, coding, and connected-service tasks.";
            mode = "inline";
            body = ''
              # Jarvis

              Treat the supplied input as the user's normal request. Answer it
              or carry out the task using the available tools and connected
              integrations as appropriate. Follow the current conversation's
              instructions and permissions. If no input was supplied, ask the
              user what they would like help with.
            '';
          }
          {
            name = "github-cli";
            description = "Use the authenticated GitHub CLI for repositories, issues, pull requests, Actions, and GitHub API requests.";
            mode = "inline";
            openclaw.requires.bins = [ "gh" ];
            body = ''
              # GitHub

              Use `gh` for authenticated GitHub operations. Authentication is
              managed by the host user's `gh auth login`, and is shared with
              this gateway. Check `gh auth status` when needed.

              Use `gh repo view OWNER/REPO`, `gh issue list --repo OWNER/REPO`,
              `gh pr list --repo OWNER/REPO`, `gh run list --repo OWNER/REPO`,
              and `gh api` for repository workflows.
            '';
          }
          {
            name = "obsidian-vault";
            description = "Search, read, and update Derek's Obsidian notes in ${vaultPath}.";
            mode = "inline";
            body = ''
              # Derek's Obsidian vault

              Vault path: `${vaultPath}`
              Vault name: `Obsidian Vault`

              Notes are Markdown files. Use file tools for direct reads,
              searches, and focused edits. Use the official `obsidian` CLI for
              Obsidian-aware operations when its CLI is enabled and the app is
              running, specifying `vault="Obsidian Vault"` when necessary.
              Preserve frontmatter and wiki-links. Use Obsidian-aware moves
              when renaming linked notes.
            '';
          }
        ];

        workspace.files."INTEGRATIONS.md" = pkgs.writeText "openclaw-INTEGRATIONS.md" ''
          # Configured integrations

          - GitHub: authenticated `gh` CLI; use the github-cli skill.
          - Google: `gog`, account `${googleAccount}`, with Gmail, Calendar,
            Drive, Docs, and Sheets authorization. Use the bundled gog skill.
          - Browser: the visible, dedicated Chromium profile named `openclaw`.
          - Obsidian: `${vaultPath}`; use the obsidian-vault skill.
          - Web search: Brave Search through the web_search tool.
          - Discord: desktop gateway only; DMs restricted to user
            `1353908629501247498`. The same owner can invoke `/jarvis input:...`
            from a user-installed app in servers, DMs, and group DMs. Replies
            are visible to everyone in the conversation. Ordinary server and
            group-DM messages stay disabled.
        '';
      };

      home.packages = [
        pkgs.gh
        gog
      ];

      home.activation.openclawGoogleKeyring =
        lib.hm.dag.entryBetween [ "reloadSystemd" ] [ "openclawDirs" ]
          ''
            run ${pkgs.coreutils}/bin/install -d -m 0700 ${lib.escapeShellArg secretDir}
            if [ ! -s ${lib.escapeShellArg googleKeyringPassword} ]; then
              run ${pkgs.coreutils}/bin/install -m 0600 /dev/null ${lib.escapeShellArg googleKeyringPassword}
              run ${pkgs.openssl}/bin/openssl rand -hex -out ${lib.escapeShellArg googleKeyringPassword} 32
            fi
            run ${pkgs.coreutils}/bin/chmod 0600 ${lib.escapeShellArg googleKeyringPassword}
          '';
    };
}
