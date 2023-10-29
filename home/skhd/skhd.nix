{pkgs, ...}:

{
  home.file.".config/skhd/skhdrc".text = ''
    # change window focus
    alt - j : yabai -m window --focus south
    alt - k : yabai -m window --focus north
    alt - h : yabai -m window --focus west
    alt - l : yabai -m window --focus east

    # move windows around in a workspace
    alt + down : yabai -m window --swap south
    alt + up : yabai -m window --swap north
    alt + left : yabai -m window --swap west
    alt + right : yabai -m window --swap east

    # move around workspaces
    alt + shift - j : yabai -m space --focus south
    alt + shift - k : yabai -m space --focus north
    alt + shift - h : yabai -m space --focus west

    # move window to another workspace
    # note that you can't follow without disabling SIP
    alt + shift + l : yabai -m window --space east
    alt + shift + h : yabai -m window --space west
    alt + shift + j : yabai -m window --space south
    alt + shift + k : yabai -m window --space north

    '';
}
