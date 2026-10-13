_: {
  flake.modules.homeManager.desktop = { lib, ... }: {
    options.my.displays = {
      niri = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = "Host-specific Niri outputs and workspace placement.";
      };
      swayOutputs = lib.mkOption {
        type = lib.types.attrsOf (lib.types.attrsOf lib.types.str);
        default = { };
        description = "Host-specific Sway output configuration.";
      };
      swayWorkspaceOutputs = lib.mkOption {
        type = lib.types.listOf (lib.types.attrsOf lib.types.str);
        default = [ ];
        description = "Host-specific Sway workspace-to-output assignments.";
      };
    };
  };
}
