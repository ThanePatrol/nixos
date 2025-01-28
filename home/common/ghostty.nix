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
  '';
}
