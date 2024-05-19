#!/bin/sh

sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos

sudo nix-channel --update

echo "changed nixos channel to unstable"

sudo nix-channel --add https://nixos.org/channels/nixpkgs-unstable

echo "changed nixos packages channel to unstable"

sudo nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager

sudo nix-channel --update

echo "added home-manager unstable channel"
