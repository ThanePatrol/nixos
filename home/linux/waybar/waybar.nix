{
  pkgs,
  lib,
  config,
  ...
}:

let
  dummy = pkgs.writeShellScriptbin "dummyScript" ''
    #!/usr/bin/env bash
    # todo make a proper script
  '';
in
{
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 24;
        spacing = 12;
        modules-left = [ "hyprland/workspaces" ];
        modules-center = [
          "clock#sydney"
          "clock#mtv"
        ];
        modules-right = [
          "network"
          "cpu"
          "memory"
          "battery"
          "pulseaudio"
          "pulseaudio/slider"
        ];
        cpu = {
          interval = 1;
          format = "{icon0}{icon1}{icon2}{icon3}{icon4}{icon5}{icon6}{icon7}{icon8}{icon9}{icon10}{icon11}{icon12}{icon13}";
          format-icons = [
            "<span color='#69ff94'>▁</span>"
            "<span color='#2aa9ff'>▂</span>"
            "<span color='#f8f8f2'>▃</span>"
            "<span color='#f8f8f2'>▄</span>"
            "<span color='#ffffa5'>▅</span>"
            "<span color='#ffffa5'>▆</span>"
            "<span color='#ff9977'>▇</span>"
            "<span color='#dd532e'>█</span>"
          ];
        };
        memory = {
          interval = 5;
          format = "{used:0.1f}G/{total:0.1f}G 󰍛";
        };

        "clock#sydney" = {
          format = "{:%a %b %d %H:%M} SYD";
          timezone = "Australia/Sydney";
          interval = 1;
        };
        "clock#mtv" = {
          format = "{:%a %b %d %H:%M} MTV";
          timezone = "America/Los_Angeles";
          interval = 1;
        };
        network = {
          format = "{icon}";
          format-alt = "{ipaddr}/{cidr} {icon}";
          format-alt-click = "click-left";
          format-icons = {
            wifi = " ";
            ethernet = "󰈀";
            disconnected = "❌";
          };
        };
        pulseaudio = {
          format = "{icon} {volume}%";
          format-alt = "{icon} {volume}%";
          format-alt-click = "click-left";
          format-icons = {
            default = [
              ""
              ""
              ""
            ];
          };
        };
        "puluseaudio/slider" = {
          min = 0;
          max = 100;
          orientation = "horizontal";
        };
        battery = {
          interval = 1;
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = " 󰂈 {capacity}%";
          format-plugged = "  {capacity}%";
          format-icons = [
            " "
            " "
            " "
            " "
            " "
          ];
        };
      };
    };
    style = builtins.readFile ./style.css;
  };
}
