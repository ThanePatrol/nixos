{ pkgs ? import <nixpkgs> { } }:

with pkgs;

mkShell {
  buildInputs = [
    go
    gotools
    gofmt
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
}
