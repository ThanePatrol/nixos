{ pkgs, theme, ... }:

let
  # read config to string
  configFileString = builtins.readFile ./config/wezterm.lua;
  # replace our theme variable with wezterm appropriate string
  # TODO - this only works because the themes only have a single m character - revise later
  themeString = builtins.replaceStrings [ "-" "m" "l" ] [ " " "M" "L" ] theme;
  #replace our placeholder text in the string
  finalConfigFileString =
    builtins.replaceStrings [ "PLACEHOLDER_THEME" ] [ themeString ]
    configFileString;
in {
  # do this rather than programs.wezterm to prevent home manager from trying to manger config files
  home.packages = [ pkgs.wezterm ];
  # would rather write lua with proper lsp support...
  # source the files and symlink them to the ~/.config/wezterm dir
  xdg.configFile."wezterm/wezterm.lua".text = finalConfigFileString;
}
