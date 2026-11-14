{
  description = "Development shell with python tools used random scripts and tax work";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";

  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      rust-overlay,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };

        rustToolchain = pkgs.pkgsBuildHost.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;

        pyPkgs = with pkgs.python312Packages; [
          pip
        ];
        nativeBuildInputs = with pkgs; [
          rustToolchain
          pkg-config

          rustPlatform.bindgenHook
          boringssl
        ];

      in
      with pkgs;
      {
        devShells.default = mkShell {
          inherit nativeBuildInputs;
          buildInputs = [
            python312
            uv
            sqlite
            cargo
            rustc
            rustfmt
            pre-commit
            rustPackages.clippy

            openssl
            pkg-config
            libsodium
            zlib
            binutils
            llvmPackages.libclang
            llvmPackages.clang
            llvmPackages.bintools
            llvmPackages.clang-tools
            cmake
          ]
          ++ pyPkgs;

          RUST_SRC_PATH = "${pkgs.latest.rustChannels.stable.rust-src}/lib/rustlib/src/rust/library";
          LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";
          BINDGEN_EXTRA_CLANG_ARGS = "-isystem ${llvmPackages.libclang.lib}/lib/clang/${lib.getVersion clang}/include";

          # shellHook = ''
          #   echo "sourcing venv"
          #   set -o allexport && source .env && set +o allexport
          #   echo "sourced venv"
          # '';

        };
      }
    );
}
