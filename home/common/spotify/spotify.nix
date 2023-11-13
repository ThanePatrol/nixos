{pkgs, ...}:
{
  home.packages = [ pkgs.spotify-player ];
  
  xdg.configFile.spotify-player = {
    source = ./config;
    recursive = true;
  };

}
