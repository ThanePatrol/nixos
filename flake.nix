{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    darwinpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    darwin.url = "github:LnL7/nix-darwin/master";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, darwin, home-manager, darwinpkgs, ... }@inputs:

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

      nixosDesktopSystem = system: username: isWork: email:
        let pkgs = genPkgs system;
        in nixpkgs.lib.nixosSystem {
          inherit system pkgs;

          specialArgs = {
            customArgs = { inherit system username isWork email; };
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

          specialArgs = {
            customArgs = { inherit system username; };
          };

          modules = [
            ./hosts/armisael/configuration.nix
          ];
        };

      darwinSystem = system: username: isWork: email:
        let pkgs = genDarwin system;
        in darwin.lib.darwinSystem {
          inherit system pkgs;

          specialArgs = {
            unstablePkgs = inputs.nixpkgs-unstable.legacyPackages.${system};
            customArgs = { inherit system username pkgs isWork email; };
          };

          modules = [
            ./hosts/leliel/darwin-configuration.nix
            home-manager.darwinModules.home-manager
          ];

        };

    in {
      darwinConfigurations = {
        # personal M1
        leliel = darwinSystem "aarch64-darwin" "hugh" false
          "mandalidis.hugh@gmail.com";
      };

      nixosConfigurations = {
        # main desktop
        ramiel =
          nixosDesktopSystem "x86_64-linux" "hugh" false "mandalidis.hugh@gmail.com";

        # lenovo m710q server
        armisael = nixosServerSystem "x86_64-linux" "hugh";
      };
    };
}
