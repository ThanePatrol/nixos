#!/usr/bin/env bash

# homebrew is required for nix darwin
# at least for the packages i use
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# configure home-brew in path
(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/"$USER"/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
echo "installed homebrew"

# install the nix package manager
sh <(curl -L https://nixos.org/nix/install)
echo "installed nix"

# may need to run the rest in a new shell
# install nix darwin
nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
./result/bin/darwin-installer
rm result
echo "installed nix darwin"

# follow unstable nix pkgs
sudo nix-channel --add https://nixos.org/channels/nixpkgs-unstable
sudo nix-channel --update
echo "changed nixos channel to unstable"

# install home-manager
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
# need to generate first home-manager generation
nix-shell '<home-manager>' -A install
echo "added home-manager unstable channel"

# Additional manaual configuration
#
# Docker desktop needs to be launched and signed into
# Missions control needs to spawn desktops 
# CHange mission control shortcuts to option + number to go to workspace
