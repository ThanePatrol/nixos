{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/master";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    golang_1_19 = {
      url = "github:NixOS/nixpkgs?rev=7a339d87931bba829f68e94621536cad9132971a";
    };

    golang_1_18 = {
      url = "github:NixOS/nixpkgs?rev=9957cd48326fe8dbd52fdc50dd2502307f188b0d";
    };

    golang_1_22 = {
      url = "github:nixos/nixpkgs?rev=05bbf675397d5366259409139039af8077d695ce";
    };

    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      nix-on-droid,
      golang_1_18,
      golang_1_19,
      golang_1_22,
      rust-overlay,
      flake-utils,
      ...
    }@inputs:
    let
      genPkgs =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      genDarwin =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

      ubuntuRemoteDevSystem =
        system: username: isWork: email: gitUserName:
        let
          pkgs = genPkgs system;
        in
        home-manager.lib.homeManagerConfiguration {
          pkgs = pkgs;
          extraSpecialArgs = {
            customArgs = {
              inherit
                system
                username
                isWork
                email
                gitUserName
                ;
            };
          };
          modules = [ ./home/home.nix ];
        };
      nixosRemoteDestopSystem =
        system: username: isWork: email: gitUserName:
        let
          pkgs = genPkgs system;
        in
        nixpkgs.lib.nixosSystem {
          inherit system pkgs;

          specialArgs = {
            customArgs = {
              inherit
                system
                username
                isWork
                email
                gitUserName
                ;
            };
          };

          modules = [
            ./hosts/zeruel/configuration.nix
            home-manager.nixosModules.home-manager
          ];

        };

      darwinSystem =
        system: username: isWork: email: gitUserName:
        let
          pkgs = genDarwin system;
        in
        nix-darwin.lib.darwinSystem {
          inherit system pkgs;

          specialArgs = {
            unstablePkgs = inputs.nixpkgs-unstable.legacyPackages.${system};
            customArgs = {
              inherit
                system
                username
                pkgs
                isWork
                email
                gitUserName
                ;
            };
          };

          modules = [
            ./hosts/leliel/darwin-configuration.nix
            home-manager.darwinModules.home-manager
          ];

        };

      androidSystem =
        system: username: isWork: email: gitUserName:
        let
          pkgs = genPkgs system;
        in
        nix-on-droid.lib.nixOnDroidConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            customArgs = {
              inherit isWork email gitUserName;
            };
          };

          modules = [
            ./hosts/fold5/nix-on-droid.nix
            {
              home-manager = {
                config = ./home/android-home.nix;
                extraSpecialArgs = {
                  customArgs = {
                    inherit
                      username
                      isWork
                      email
                      gitUserName
                      ;
                  };
                };
              };
            }
          ];
        };

      makeRustDevShell =
        system:
        let
          overlays = [ (import rust-overlay) ];
          pkgs = import nixpkgs { inherit system overlays; };
          rustToolchain = pkgs.pkgsBuildHost.rust-bin.fromRustupToolchainFile ./shells/rust-toolchain.toml;
          nativeBuildInputs = with pkgs; [
            rustToolchain
            pkg-config
          ];
          buildInputs =
            with pkgs;
            [
              openssl
            ]

            # needed for linker errors, add others as needed
            ++ (with darwin.apple_sdk.frameworks; [
              System
              SystemConfiguration
            ]);
        in
        pkgs.mkShell {
          inherit buildInputs nativeBuildInputs;

          # https://discourse.nixos.org/t/rust-src-not-found-and-other-misadventures-of-developing-rust-on-nixos/11570/4
          RUST_SRC_PATH = "${pkgs.latest.rustChannels.stable.rust-src}/lib/rustlib/src/rust/library";
          shellHook = "";
        };

    in
    {
      darwinConfigurations = {
        # personal M1
        leliel = darwinSystem "aarch64-darwin" "hugh" false "mandalidis.hugh@gmail.com" "Hugh Mandalidis";
        # TikTok M2
        work =
          darwinSystem "aarch64-darwin" "bytedance" true "hugh.mandalidis@bytedance.com"
            "hugh.mandalidis";
      };

      nixosConfigurations = {
        # main desktop
        ramiel =
          nixosRemoteDestopSystem "x86_64-linux" "hugh" false "mandalidis.hugh@gmail.com"
            "Hugh Mandalidis";

        # x570 server
        zeruel =
          nixosRemoteDestopSystem "x86_64-linux" "hugh" false "mandalidis.hugh@gmail.com"
            "Hugh Mandalidis";
      };

      homeConfigurations = {
        workServer =
          ubuntuRemoteDevSystem "x86_64-linux" "hugh.mandalidis" true "hugh.mandalidis@bytedance.com"
            "hugh.mandalidis";
      };

      androidConfigurations = {
        fold5 =
          androidSystem "aarch64-linux" "nix-on-droid" false "mandalidis.hugh@gmail.com"
            "Hugh Mandalidis";
      };

      rustStableDevShell = makeRustDevShell "aarch64-darwin";

      devShells.aarch64-darwin = {
        go_1_18 =
          let
            pkgs = golang_1_18.legacyPackages.aarch64-darwin;
          in
          pkgs.mkShell {
            buildInputs = with pkgs; [
              go_1_18
              go-tools
              golangci-lint
              golines
            ];
          };
        go_1_19 =
          let
            pkgs = golang_1_19.legacyPackages.aarch64-darwin;
          in
          pkgs.mkShell {
            buildInputs = with pkgs; [
              go_1_19
              go-tools
              golangci-lint
              nilaway
              golines
            ];
          };
        go_1_22 =
          let
            pkgs = golang_1_22.legacyPackages.aarch64-darwin;
          in
          pkgs.mkShell {
            buildInputs = with pkgs; [
              go_1_22
              go-tools
              golangci-lint
              nilaway
              golines
              tinygo
              python39
              python39Packages.pip
            ];
          };
      };
    };
}
