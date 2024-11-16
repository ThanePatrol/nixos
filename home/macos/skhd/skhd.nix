{ pkgs, ... }:

let
  mod = "alt";

in
{
  home.file.".config/skhd/skhdrc" = {
    executable = true;
    text = ''
            # change window focus
            ${mod} - j : yabai -m window --focus south
            ${mod} - k : yabai -m window --focus north
            ${mod} - h : yabai -m window --focus west
            ${mod} - l : yabai -m window --focus east

            # move windows around in a workspace
      #      ${mod} - down : yabai -m window --swap south
      #      ${mod} - up : yabai -m window --swap north
      #      ${mod} - left : yabai -m window --swap west
      #      ${mod} - right : yabai -m window --swap east

            # move window to another workspace
            # note that you can't follow without disabling SIP
            ${mod} + shift - j : yabai -m window --space prev
            ${mod} + shift - k : yabai -m window --space next

            # move window to space
            shift + ${mod} - 1 : yabai -m window --space 1
            shift + ${mod} - 2 : yabai -m window --space 2
            shift + ${mod} - 3 : yabai -m window --space 3
            shift + ${mod} - 4 : yabai -m window --space 4
            shift + ${mod} - 5 : yabai -m window --space 5
            shift + ${mod} - 6 : yabai -m window --space 6
            shift + ${mod} - 7 : yabai -m window --space 7
    '';
  };
}
