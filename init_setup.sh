#!/bin/sh

nix-channel --add https://github.com/nix-community/home-manager/archive/release-23.05.tar.gz home-manager

nix-channel --update

echo "added home-manager channel"
