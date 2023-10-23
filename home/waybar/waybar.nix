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
        modules-right = [ "pulseaudio" "network" "cpu" ];
        clock = {
          format = "{:%a %b %d %H:%M}";
          interval = 1;
        };
        network = {
          format = "{icon}";
          format-alt = "{ipaddr}/{cidr} {icon}";
          format-alt-click = "click-left";
          format-icons = {
            wifi = " ";
            ethernet = "🔗 "; # TODO - find a better icon
            disconnected = "❌";
          };
        };
        pulseaudio = {
          format = "{icon}";
          format-alt = "{icon} {volume}%";
          format-alt-click = "click-left";
          format-icons = { default = [ "" "" "" ]; };
          # TODO pipewire volume control
        };
      };
    };
    style = builtins.readFile ./style.css;
  };
}
