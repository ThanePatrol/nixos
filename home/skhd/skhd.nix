{pkgs, ...}:

{
  home.file.".config/skhd/skhdrc".text = ''
    # change window focus
    cmd - j : yabai -m window --focus south
    cmd - k : yabai -m window --focus north
    cmd - h : yabai -m window --focus west
    cmd - l : yabai -m window --focus east

    # move windows around in a workspace
    cmd + down : yabai -m window --swap south
    cmd + up : yabai -m window --swap north
    cmd + left : yabai -m window --swap west
    cmd + right : yabai -m window --swap east

    # move around workspaces
    cmd + shift - j : yabai -m space --focus south
    cmd + shift - k : yabai -m space --focus north
    cmd + shift - h : yabai -m space --focus west

    # move window to another workspace
    # note that you can't follow without disabling SIP
    cmd + shift + l : yabai -m window --space east
    cmd + shift + h : yabai -m window --space west
    cmd + shift + j : yabai -m window --space south
    cmd + shift + k : yabai -m window --space north

    '';
}
