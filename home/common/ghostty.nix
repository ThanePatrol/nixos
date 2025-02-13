{
  lib,
  theme,
  ...
}:

let
  themeString = lib.toLower theme;
in
{
  xdg.configFile."ghostty/config".text = ''
    theme = ${themeString}
    font-size = 16

    clipboard-read = allow
    clipboard-write = allow

    keybind = cmd+shift+d=new_split:right

    keybind = cmd+h=goto_split:left
    keybind = cmd+j=goto_split:down
    keybind = cmd+k=goto_split:up
    keybind = cmd+l=goto_split:right
  '';
}
