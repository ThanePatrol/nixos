#!/usr/bin/env bash

tmux new -s programs -d
tmux send-keys -t programs "skhd --stop-service" ENTER
tmux send-keys -t programs "skhd -V" ENTER
echo "skhd service started."
