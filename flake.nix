{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    darwinpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    darwin.url = "github:LnL7/nix-darwin/master";

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

  };

  outputs = { self, nixpkgs, darwin, home-manager, darwinpkgs, nix-on-droid
    , golang_1_18, golang_1_19, golang_1_22, ... }@inputs:
    let
      genPkgs = system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      genDarwin = system:
        import darwinpkgs {
          inherit system;
          config.allowUnfree = true;
        };



      ubuntuRemoteDevSystem = system: username: isWork: email: gitUserName:
        let pkgs = genPkgs system;
        in home-manager.lib.homeManagerConfiguration {
          pkgs = pkgs;
          extraSpecialArgs = {
            customArgs = { inherit system username isWork email gitUserName; };
          };
          modules = [ 
            ./home/home.nix
          ];
        };
      nixosDesktopSystem = system: username: isWork: email: gitUserName:
        let pkgs = genPkgs system;
        in nixpkgs.lib.nixosSystem {
          inherit system pkgs;

          specialArgs = {
            customArgs = { inherit system username isWork email gitUserName; };
          };

          modules = [
            ./hosts/ramiel/configuration.nix
            home-manager.nixosModules.home-manager
          ];

        };

      nixosServerSystem = system: username:
        let pkgs = genPkgs system;
        in nixpkgs.lib.nixosSystem {
          inherit system pkgs;

          specialArgs = { customArgs = { inherit system username; }; };

          modules = [ ./hosts/armisael/configuration.nix ];
        };

      darwinSystem = system: username: isWork: email: gitUserName:
        let pkgs = genDarwin system;
        in darwin.lib.darwinSystem {
          inherit system pkgs;

          specialArgs = {
            unstablePkgs = inputs.nixpkgs-unstable.legacyPackages.${system};
            customArgs = {
              inherit system username pkgs isWork email gitUserName;
            };
          };

          modules = [
            ./hosts/leliel/darwin-configuration.nix
            home-manager.darwinModules.home-manager
          ];

        };

      androidSystem = username: isWork: email: gitUserName:
        nix-on-droid.lib.nixOnDroidConfiguration {
          #inherit system pkgs;
          extraSpecialArgs = {
            customArgs = { inherit isWork email gitUserName; };
          };

          modules = [
            ./hosts/fold5/nix-on-droid.nix
            {
              home-manager = {
                config = ./home/android-home.nix;
                extraSpecialArgs = {
                  customArgs = { inherit username isWork email gitUserName; };
                };
              };
            }
          ];
        };

        makeGolangShell = goVersionPkgs: nixpkgsVersion:
        
        let 
          pkgs = nixpkgsVersion.legacyPackages.aarch64-darwin;
          commonPkgs = with pkgs; [
            go-tools
            golangci-lint
          ];
        in 
        pkgs.mkShell { 
          buildInputs = with pkgs; [
            goVersionPkgs 
          ] ++ commonPkgs; 
        };

    in {
      darwinConfigurations = {
        # personal M1
        leliel =
          darwinSystem "aarch64-darwin" "hugh" false "mandalidis.hugh@gmail.com"
          "Hugh Mandalidis";
        # TikTok M2
        work = darwinSystem "aarch64-darwin" "bytedance" true
          "hugh.mandalidis@bytedance.com" "hugh.mandalidis";
      };

      nixosConfigurations = {
        # main desktop
        ramiel = nixosDesktopSystem "x86_64-linux" "hugh" false
          "mandalidis.hugh@gmail.com" "Hugh Mandalidis";

        # lenovo m710q server
        armisael = nixosServerSystem "x86_64-linux" "hugh";

      };

      homeConfigurations = {
        work-server =
          ubuntuRemoteDevSystem "x86_64-linux" "hugh.mandalidis" true
          "hugh.mandalidis@bytedance.com" "hugh.mandalidis";
      };

      androidConfigurations = {
        fold5 = androidSystem "nix-on-droid" false "mandalidis.hugh@gmail.com"
          "Hugh Mandalidis";
      };

      devShells.aarch64-darwin = {
        go_1_18 = let pkgs = golang_1_18.legacyPackages.aarch64-darwin;
        in pkgs.mkShell { buildInputs = with pkgs; [ go_1_18 go-tools golangci-lint ]; };
        go_1_19 = let pkgs = golang_1_19.legacyPackages.aarch64-darwin;
        in pkgs.mkShell { buildInputs = with pkgs; [ go_1_19 go-tools golangci-lint nilaway]; };
        go_1_22 = let pkgs = golang_1_22.legacyPackages.aarch64-darwin;
        in pkgs.mkShell { buildInputs = with pkgs; [ go_1_22 go-tools golangci-lint nilaway]; };
#        go_1_18 = makeGolangShell [ golang_1_18.go_1_18 ] golang_1_18;
#        go_1_19 = makeGolangShell [ golang_1_19.go_1_19 ] golang_1_19;
#        go_1_22 = makeGolangShell [ golang_1_22.go_1_22 golang_1_22.nilaway ] golang_1_22;
      };
    };
}
