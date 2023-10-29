{ pkgs, ... }:

{
  home.file.".config/skhd/skhdrc" = {
    executable = true;
    text = ''
      # change window focus
      alt - j : yabai -m window --focus south
      alt - k : yabai -m window --focus north
      alt - h : yabai -m window --focus west
      alt - l : yabai -m window --focus east

      # move windows around in a workspace
      alt - down : yabai -m window --swap south
      alt - up : yabai -m window --swap north
      alt - left : yabai -m window --swap west
      alt - right : yabai -m window --swap east

      # move window to another workspace
      # note that you can't follow without disabling SIP
      alt + shift - j : yabai -m window --space prev
      alt + shift - k : yabai -m window --space next

      # move window to space
      shift + alt - 1 : yabai -m window --space 1
      shift + alt - 2 : yabai -m window --space 2
      shift + alt - 3 : yabai -m window --space 3
      shift + alt - 4 : yabai -m window --space 4
      shift + alt - 5 : yabai -m window --space 5
      shift + alt - 6 : yabai -m window --space 6
      shift + alt - 7 : yabai -m window --space 7

    '';
  };
}
