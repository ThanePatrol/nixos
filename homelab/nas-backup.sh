#!/usr/bin/env bash
#
#TODO - migrate rockpros to nixos

#TODO - do a check to make sure rclone is installed + this will run on the correct file paths + disks
# Assumes rclone has been setup here: https://rclone.org/b2/
# Interesting router config using nix:https://www.jjpdev.com/posts/home-router-nixos/  

sudo mount -a
rclone sync --interactive /mnt/samsung4tb/nas /mnt/ironwolf1/nas
rclone sync --interactive /mnt/samsung4tb/nas b2-nas-backup:thane-patrol-ironwolfs
sudo umount /dev/sda

