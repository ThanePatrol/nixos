{ pkgs, lib, config, ... }:

let 
    dummy = pkgs.writeShellScriptbin "dummyScript" ''
        #!/usr/bin/env bash
        # todo make a proper script
    '';
in {
    programs.waybar = {
        enable = true;
        package = pkgs.waybar;
        settings = {
            mainBar = {
                layer = "top";
                position = "top";
                height = 24;
                spacing = 7;
                modules-left = [
                    "hyprland/workspaces" # todo - add more modules like battery, etc
                ];
                modules-center = [
                    "clock" # todo - add weather
                ];
                modules-right = [
                    "pulseaudio" "network" "cpu" "memory"
                ];

            };
        };
    };
}
