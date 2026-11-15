{
  lib,
  buildLinux,
  fetchFromGitHub,
  fetchurl,
  baseKernel,
}:
buildLinux {
  pname = "linux-asahi-fairydust";
  version = "7.1.13";
  modDirVersion = "7.1.13-fairydust";
  extraMeta.branch = "7.1";
  inherit (baseKernel) features extraMakeFlags;

  src = fetchFromGitHub {
    owner = "AsahiLinux";
    repo = "linux";
    rev = "ce9f2eba72c061a50b2d790450e90af3439d8c24";
    hash = "sha256-W3yMSUe6xa+M/X0k86kbCS4g3d7jJmO3WV9L/5rQRhI=";
  };

  # This Fairydust revision predates two fixes in asahi-7.1.13-3. Carry
  # those forward as well as the upstream module's Asahi/Rust configuration.
  kernelPatches = baseKernel.kernelPatches ++ [
    {
      name = "apple-speaker-jack-nodes";
      patch = fetchurl {
        url = "https://github.com/AsahiLinux/linux/commit/13aba96fb344feb5708d998c54331a719431a3db.patch";
        hash = "sha256-AU3Ar1Y75G6J1+a8emEShhrAYR53Rrbea+uMsvLumMQ=";
      };
    }
    {
      name = "brcmfmac-port-authorized";
      patch = fetchurl {
        url = "https://github.com/AsahiLinux/linux/commit/94fb23346d522edf53722357c426a3e58030beea.patch";
        hash = "sha256-HSniRz+798FRejlm8nTlT+MVUeKCQ6eFoz9kV1TqVUQ=";
      };
    }
  ];

  structuredExtraConfig =
    baseKernel.structuredExtraConfig
    // (with lib.kernel; {
      LOCALVERSION = freeform "-fairydust";
      # Uncompressed DWARF exhausts the MacBook's build disk at vmlinux link.
      # Compress it for C and Rust while retaining debug symbols and BTF.
      DEBUG_INFO_COMPRESSED_NONE = no;
      DEBUG_INFO_COMPRESSED_ZLIB = yes;
      PHY_APPLE_ATC = module;
      PHY_APPLE_DPTX = module;
      MUX_APPLE_DPXBAR = module;
      TYPEC_TPS6598X = module;
      TYPEC_DP_ALTMODE = module;
    });
}
