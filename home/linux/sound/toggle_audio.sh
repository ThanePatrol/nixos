#!/usr/bin/env bash

# simply toggles between audio and headset
# Find the device names with `pactl list sinks`
HEADSET="alsa_output.usb-Unknown_manufacturer_ATH-G1WL_0546148060-00.analog-stereo"
SPEAKER="alsa_output.usb-CalDigit_Inc._CalDigit_TS4_Audio_-_Rear-00.analog-stereo"

CURRENT_DEV=$(pactl info | grep 'Default Sink' | cut -d' ' -f3)

if [ "$CURRENT_DEV" = "$HEADSET" ]; then
	pactl set-default-sink "$SPEAKER"
else
	pactl set-default-sink "$HEADSET"
fi
