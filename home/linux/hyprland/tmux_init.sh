#!/usr/bin/env bash

tmux new -d -s dev
tmux new -d -s nix
tmux new -d -s uni

tmux send-keys -t nix "cd nixos" ENTER
tmux send-keys -t dev "cd IdeaProjects" ENTER
