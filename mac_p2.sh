#!/usr/bin/env bash
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
# Docker desktop needs to be launched at least once
# Missions control needs to spawn desktops 
# CHange mission control shortcuts to option + number to go to workspace

