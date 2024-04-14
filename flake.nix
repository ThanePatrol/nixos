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
      url = "github:nix-community/nix-on-droid/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, darwin, home-manager, darwinpkgs, nix-on-droid, ... }@inputs:
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
            customArgs = {
              inherit isWork email gitUserName;
            };
          };

          modules = [
            ./hosts/fold5/nix-on-droid.nix
            home-manager.nixOnDroid.home-manager
          ];
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

      androidConfigurations = {
        fold5 = androidSystem "nix-on-droid" false "mandalidis.hugh@gmail.com" "Hugh Mandalidis";
      };
    };
}
