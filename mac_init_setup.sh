#!/usr/bin/env bash

# homebrew is required for nix darwin
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo "installed homebrew"

# install the nix package manager
sh <(curl -L https://nixos.org/nix/install)
echo "installed nix"

# install nix darwin
nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
./result/bin/darwin-installer
echo "installed nix darwin"

# follow unstable nix
sudo nix-channel --add https://nixos.org/channels/nixpkgs-unstable
sudo nix-channel --update
echo "changed nixos channel to unstable"

# install home-manager
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
echo "added home-manager unstable channel"
