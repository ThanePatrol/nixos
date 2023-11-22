{ pkgs ? import <nixpkgs> { } }:

with pkgs;

mkShell {
  buildInputs = [
    go
    gotools
    gopls
    go-outline
    gocode
    gopkgs
    gocode-gomod
    godef
    golint
    nodePackages.rollup
    nodejs_20
  ];

  shellHook = ''
  # add random env vars here if needed
    export GOPATH=$HOME/go
    export PATH=$PATH:$GOPATH/bin
    export PATH=$PATH:/opt/atlassian/bin

    # decided not to include this as it's a bit of hack, not declarative so defeats the
    # point of having it
   # if [ -e /opt/atlassian/bin/atlas ] then
   #   echo "atlas not found, installing..."
   #   $(curl -fsSL https://statlas.prod.atl-paas.net/atlas-cli/install.sh)
   #   /opt/atlassian/bin/atlas plugin install -n packages
   # fi 
  '';
}
