{pkg, ...}:

{
  home.file."./config/yabai/yabairc".text = ''
  
  yabai -m config layout bsp # binary space partitioning
  yabai -m config window_placement second_child 

  # padding
  yabai -m config top_padding 12
  yabai -m config bottom_padding 12
  yabai -m config left_padding 12
  yabai -m config right_padding 12
  yabai -m config window_gap 12


  # mouse memes
  yabai -m config mouse_follows_focus on
  yabai -m config mouse_modifier alt
  yabai -m config mouse_action1 move # left click + drag
  yabai -m config mouse_action2 resize # right click + drag
  yabai -m mouse_drop_action swap

  # don't allow yabai to tile
  yabai -m rule --add app="^System Settings$" manage=off
  yabai -m rule --add app="^Calculator$" manage=off
  '';

}
