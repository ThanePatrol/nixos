{pkgs, ...}:
{
  # do this rather than programs.wezterm to prevent home manager from trying to manger config files
  home.packages = [ pkgs.wezterm ]; 
  # would rather write lua with proper lsp support...
  # source the files and symlink them to the ~/.config/wezterm dir
  xdg.configFile.wezterm = {
    source = ./config;
    recursive = true;
  };

}
