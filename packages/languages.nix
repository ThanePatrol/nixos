{ pkgs }:

let
  mozillaOverlay = import (builtins.fetchTarball
    "https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz");

  nixpkgs = import <nixpkgs> { overlays = [ mozillaOverlay ]; };

in {
  environment.systemPackages = with pkgs; [
    nixpkgs.rustChannels.stable.rust
    nixpkgs.rustChannels.nightly.rust
    python3
    nodejs
    openjdk
    scala
  ];
}
