{ pkgs }:

let
  mozillaOverlay = import (builtins.fetchTarball
  "https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz");

  # removed in flake port

  #nixpkgs = import <nixpkgs> { overlays = [ mozillaOverlay ]; };

in {
  environment.systemPackages = with pkgs; [
    rustc
    python3
    nodejs
    openjdk
    scala
    go
  ];
}
