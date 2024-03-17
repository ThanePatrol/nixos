{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    darwinpkgs.url = "github:NixOS/nixpkgs/nixpkgs-23.11-darwin";
    darwin.url = "github:LnL7/nix-darwin/master";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{
    self, nixpkgs, darwin, home-manager, darwinpkgs, ...
  }:

  let
    inputs = { inherit nixpkgs darwin home-manager darwinpkgs; };

    genPkgs = system: import nixpkgs { inherit system; config.allowUnfree = true; };
    genDarwin = system: import darwinpkgs { inherit system; config.allowUnfree = true; };

    nixosSystem = system: username: isWork:
      let 
        pkgs = genPkgs system;
      in
        nixpkgs.lib.nixosSystem {
          inherit system pkgs;

          specialArgs = {
            customArgs = { inherit system username isWork; };
          };

          modules = [
            ./hosts/ramiel/configuration.nix
          ];

        };

    darwinSystem = system: username: isWork:
      let 
        pkgs = genDarwin system;
      in
        darwin.lib.darwinSystem {
          inherit system;

          specialArgs = {
            unstablePkgs = inputs.nixpkgs-unstable.legacyPackages.${system};

            customArgs = { inherit system username pkgs isWork; };
          };

          modules = [
            ./darwin-configuration.nix
          ];

        };
    
  in {
    darwinConfigurations = {
      # personal M1
      stickerbook = darwinSystem "aarch64-darwin" "hugh" "false";
    };

    nixosConfigurations = {
      # main desktop
      ramiel = nixosSystem "x86_64-linux" "hugh" "false";
    };

  };


}
