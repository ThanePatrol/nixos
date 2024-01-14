{ theme, ... }:

{
  programs.bat = {
    enable = true;
     
    config = { theme = theme; };

  };

  xdg.configFile."bat/themes/${theme}.tmTheme".text = 
  builtins.readFile ./themes/${theme}.tmTheme;
}
