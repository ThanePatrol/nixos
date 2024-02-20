{pkgs, ...}:
# FIXME - take inputs to read these
{

  services.sonarr = {
    enable = true;
    dataDir = "/home/hugh/.config";
  };

  services.radarr = {
    enable = true;
    dataDir = "/home/hugh/.config";
  };

  services.transmission = {
    enable = true;
    home = /home/hugh/.config;
    settings = {
      download-dir = "/nfs/samsung4tb/Content/Downloads";
      webHome = pkgs.flood;
    };
  };
}
