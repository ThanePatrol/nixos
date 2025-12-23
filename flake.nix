{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/master";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
    };

    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      rust-overlay,
      flake-utils,
      neovim-nightly-overlay,
      sops-nix,
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

      vpsSystem =
        system: username: isWork: email: gitUserName: homeDirectory: minimal:
        let
          pkgs = genPkgs system;
          isDarwin = false;
        in
        home-manager.lib.homeManagerConfiguration {
          pkgs = pkgs;
          extraSpecialArgs = {
            customArgs = {
              inherit
                system
                username
                isWork
                isDarwin
                email
                gitUserName
                homeDirectory
                minimal
                ;
            };
          };
          modules = [
            (import ./home/home.nix {
              inputs = inputs;
              email = email;
              isWork = isWork;
              isDarwin = isDarwin;
              username = username;
              gitUserName = gitUserName;
              theme = "Catppuccin-mocha";
              homeDirectory = homeDirectory;
              minimal = minimal;
              pkgs = pkgs;
              lib = pkgs.lib;
            })
          ];
        };
      nixosRemoteDestopSystem =
        system: username: isWork: email: gitUserName: homeDirectory:
        let
          pkgs = genPkgs system;
        in
        nixpkgs.lib.nixosSystem {
          inherit system pkgs;

          specialArgs = {
            customArgs = {
              inherit
                inputs
                system
                username
                isWork
                email
                gitUserName
                homeDirectory
                ;
            };
          };

          modules = [
            ./hosts/zeruel/configuration.nix
            home-manager.nixosModules.home-manager
            sops-nix.nixosModules.sops
          ];

        };

      darwinSystem =
        system: username: isWork: email: gitUserName: homeDirectory:
        let
          pkgs = genDarwin system;
        in
        nix-darwin.lib.darwinSystem {
          inherit system pkgs;

          specialArgs = {
            unstablePkgs = inputs.nixpkgs-unstable.legacyPackages.${system};
            customArgs = {
              inherit
                inputs
                system
                username
                pkgs
                isWork
                email
                gitUserName
                homeDirectory
                ;
            };
          };

          modules = [
            ./hosts/leliel/darwin-configuration.nix
            home-manager.darwinModules.home-manager
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
            ++ (
              if system == "aarch64-darwin" then
                (with darwin.apple_sdk.frameworks; [
                  System
                  SystemConfiguration
                ])
              else
                [ ]
            );
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
        leliel =
          darwinSystem "aarch64-darwin" "hugh" false "mandalidis.hugh@gmail.com" "Hugh Mandalidis"
            "/Users/hugh";
        # Google m3
        work =
          darwinSystem "aarch64-darwin" "hmandalidis" true "hmandalidis@google.com" "hugh.mandalidis"
            "/Users/hmandalidis";
      };

      nixosConfigurations = {
        # x570 server
        zeruel =
          nixosRemoteDestopSystem "x86_64-linux" "hugh" false "mandalidis.hugh@gmail.com" "Hugh Mandalidis"
            "/home/hugh";
      };

      homeConfigurations = {
        workServer =
          vpsSystem "x86_64-linux" "hmandalidis" true "hmandalidis@google.com" "hmandalidis"
            "/usr/local/google/home/hmandalidis"
            false;
        # first oracle vps
        oracleServer =
          vpsSystem "x86_64-linux" "ubuntu" false "mandalidis.hugh@gmail.com" "hmandalidis" "/home/ubuntu"
            true;
      };

      rustStableDarwinDevShell = makeRustDevShell "aarch64-darwin";

      devShells.aarch64-darwin = {
      };
    };
}
