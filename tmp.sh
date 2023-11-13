#!/usr/bin/env bash

# configure home-brew in path
(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/hugh/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"


# add yabai
brew install koekeishiya/formulae/yabai
start yabai services

# Docker desktop needs to be launched
# Missions control needs to spawn desktops 
# CHange mission control shortcuts to option + number to go to workspace

# need to generate first home-manager generation
nix-shell '<home-manager>' -A install

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
