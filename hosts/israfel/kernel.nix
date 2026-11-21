{
  lib,
  pkgs,
  config,
  ...
}:
let
  # linux-asahi at the fairydust branch (DisplayPort Alt Mode over USB-C),
  # same version and structuredExtraConfig as upstream linux-asahi in
  # nixos-apple-silicon, only the source commit differs.
  linux-fairydust = pkgs.callPackage (
    {
      stdenv,
      lib,
      fetchFromGitHub,
      buildLinux,
      linuxPackagesFor,
      _kernelPatches ? [ ],
    }:
    let
      kernel = buildLinux {
        inherit stdenv lib;
        pname = "linux-asahi";
        version = "7.2.15-fairydust";
        modDirVersion = "7.2.15-fairydust";
        extraMeta.branch = "7.2";
        src = fetchFromGitHub {
          owner = "AsahiLinux";
          repo = "linux";
          rev = "432e09dca5d88e145eba6ff6080cd77aa5b8ccf8";
          hash = "sha256-oB40IG6UgwgklAO8J09KY8/FPzF5nklvKvZe8A2/2Pg=";
        };
        kernelPatches = [
          {
            name = "Asahi config";
            patch = pkgs.writeText "fix-tools-u128.patch" ''
              diff --git a/tools/build/Makefile.build b/tools/build/Makefile.build
              --- a/tools/build/Makefile.build
              +++ b/tools/build/Makefile.build
              @@ -25,2 +25,4 @@
               
              +CFLAGS += -D__u128=__uint128_t
              +
               __build: $(if $(KBUILD_BUILTIN),$(builtin-target) $(lib-target)) \
            '';
            structuredExtraConfig = with lib.kernel; {
              # Needed for GPU
              ARM64_16K_PAGES = yes;

              ARM64_MEMORY_MODEL_CONTROL = yes;
              ARM64_ACTLR_STATE = yes;

              # Might lead to the machine rebooting if not loaded soon enough
              APPLE_WATCHDOG = yes;

              # Can not be built as a module, defaults to no
              APPLE_M1_CPU_PMU = yes;

              # Defaults to 'y', but we want to allow the user to set options in modprobe.d
              HID_APPLE = module;

              APPLE_PMGR_MISC = yes;
              APPLE_PMGR_PWRSTATE = yes;
            };
            features.rust = true;
          }
          {
            name = "fairydust config";
            patch = null;
            structuredExtraConfig = with lib.kernel; {
              RUST = yes;
              LOCALVERSION = freeform "-fairydust";

              DRM_ASAHI = module;
              DRM_APPLE = module;

              RUST_FW_LOADER_ABSTRACTIONS = yes;
              RUST_DRM_SCHED = yes;
              RUST_DRM_GEM_SHMEM_HELPER = yes;
              RUST_DRM_GPUVM = yes;
              RUST_APPLE_MAILBOX = yes;
              RUST_APPLE_RTKIT = yes;

              TYPEC_DP_ALTMODE = module;
              TYPEC_NVIDIA_ALTMODE = module;
              TYPEC_TBT_ALTMODE = module;
            };
            features.rust = true;
          }
        ]

        ++ _kernelPatches;
      };
    in
    lib.recurseIntoAttrs (linuxPackagesFor kernel)
  ) { _kernelPatches = config.boot.kernelPatches; };
in
{
  boot = {
    kernelPackages = lib.mkForce linux-fairydust;
    initrd.kernelModules = [
      "appledrm"
      "mux_apple_display_crossbar"
    ];
    binfmt = {
      emulatedSystems = [
        # "armv7l-linux"
        # "x86_64-linux"
      ];
      preferStaticEmulators = true;
    };
  };
}
