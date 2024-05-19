#!/usr/bin/env bash
#
#
# TODO - this isn't working :(
# Spent a few hours trying to get it to work
# Script works when run manually but not as a udev rule :shrug:
echo "please help me" >/tmp/sanity-check.log
echo "$1 and $2" >/tmp/output-mount.log
device_name="$1"

systemd_mount_path="$2/bin/systemd-mount"

#lsblk to get device label name, remove the other output from the command including newlines
disk_label="$(lsblk -o label $device_name | sed -e 's/LABEL//' | tr -d '\n')"

mount_point="/home/hugh/removable/$disk_label"
mkdir -p "$mount_point"

command="$systemd_mount_path --no-block --automount=yes --collect $device_name $mount_point"
echo "$command" >/tmp/output-mount.log
eval $command
