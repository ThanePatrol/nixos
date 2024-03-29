with (import <nixpkgs> { });

let
  jest = pkgs.stdenv.mkDerivation rec {
    name = "jest-${version}";
    version = "git-2023-11-24";

    src = pkgs.fetchFromGitHub {
      owner = "jestjs";
      repo = "jest";
      rev = "2c3d2409879952157433de215ae0eee5188a4384";
      sha256 = "sha256-zCkUgomT5btRL1X06wt8natklsALyse0ga5GejImJzo=";
    };
    buildInputs = [ pkgs.nix ];
    buildPhase = ''
      nix-build ${src}/release.nix
    '';
  };

in mkShell {

  buildInputs = [
    #go
    #gotools
    #gopls
    #go-outline
    #gocode
    #gopkgs
    #gocode-gomod
    #godef
    #golint
    #nodePackages.rollup
    #nodejs_20
    (import "${jestDerivation}/release.nix")
  ];

  shellHook = ''
    # add random env vars here if needed
      export GOPATH=$HOME/go
      export PATH=$PATH:$GOPATH/bin
      export PATH=$PATH:/opt/atlassian/bin

  '';
}
