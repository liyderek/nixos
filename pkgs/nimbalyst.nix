{
  lib,
  appimageTools,
  fetchurl,
}:
appimageTools.wrapType2 {
  pname = "nimbalyst";
  version = "0.72.8";

  src = fetchurl {
    url = "https://github.com/nimbalyst/nimbalyst/releases/download/v0.72.8/Nimbalyst-Linux.AppImage";
    hash = "sha256-tTcjKhly9mUyS1mLWpvNCb4zXwAFfeb3QXGWWxrIOdA=";
  };

  meta = {
    description = "Visual editor and workspace for Claude Code and Codex";
    homepage = "https://nimbalyst.com";
    license = lib.licenses.mit;
    platforms = ["x86_64-linux"];
    mainProgram = "nimbalyst";
  };
}
