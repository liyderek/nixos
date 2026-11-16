{
  discord,
  nodejs,
}:
let
  patched = discord.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./openclaw-discord-personal-jarvis.patch ];
    postPatch = (old.postPatch or "") + ''
      cp ${./openclaw-discord-personal-jarvis.mjs} dist/.setup/personal-jarvis.mjs
    '';
    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck
      HOME="$TMPDIR/jarvis-check-home" ${nodejs}/bin/node ${./openclaw-discord-personal-jarvis-check.mjs} "$out"
      runHook postInstallCheck
    '';
    passthru = (old.passthru or { }) // {
      openclawRuntimePlugin = old.passthru.openclawRuntimePlugin // {
        loadPath = patched;
      };
    };
  });
in
patched
