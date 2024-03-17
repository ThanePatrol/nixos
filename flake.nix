{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    darwin-pkgs = "github:NixOS/nixpkgs/nixpkgs-unstable-darwin";
    darwin.url = "github:LnL7/nix-darwin/master";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{
    self, nixpkgs, darwin, home-manager, darwin-pkgs, ...
  }:

  let
    inputs = { inherit nixpkgs darwin home-manager darwin-pkgs; };

    genPkgs = system: import nixpkgs { inherit system; config.allowUnfree = true; };
    genDarwin = system: import darwin-pkgs { inherit system; config.allowUnfree = true; };

    nixSystem = system: username: isWork:
      let 
        pkgs = genDarwin system;
      in
        darwin.lib.darwinSystem {
          inherit system inputs;

          specialArgs = {
            unstablePkgs = inputs.nixpkgs-unstable.legacyPackages.${system};

            customArgs = { inherit system username pkgs isWork; };
          };

          modules = [
            ./darwin-configuration.nix
          ];

        };

    darwinSystem = system: username: isWork:
      let 
        pkgs = genDarwin system;
      in
        darwin.lib.darwinSystem {
          inherit system inputs;

          specialArgs = {
            unstablePkgs = inputs.nixpkgs-unstable.legacyPackages.${system};

            customArgs = { inherit system username pkgs isWork; };
          };

          modules = [
            ./darwin-configuration.nix
          ];

        };
    
  in 
    darwinConfigurations = {
      # personal M1
      stickerbook = darwinSystem "aarch64-darwin" "hugh" "false";
    };


}
