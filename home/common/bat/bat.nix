{ pkgs, ... }:

{
  programs.bat = {
    enable = true;

    config = { theme = "Catppuccin-mocha"; };

  };

  xdg.configFile."bat/themes/Catppuccin-mocha.tmTheme".text = 
  builtins.readFile ./themes/Catppuccin-mocha.tmTheme;
}
