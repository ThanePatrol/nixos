#!/usr/bin/env bash

argument=$1
if [ "$argument" = "speaker-volume" ]; then
	wpctl get-volume @DEFAULT_AUDIO_SINK@ | sed s/Volume:\ /100\*/ | bc | sed s/\.00/%/
elif [ "$argument" = "mic-volume" ]; then
	wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | sed s/Volume:\ /100\*/ | bc | sed s/\.00/%/
fi
