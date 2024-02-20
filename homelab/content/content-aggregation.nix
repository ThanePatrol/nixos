{pkgs, ...}:
# FIXME - take inputs to read these
{

  services.sonarr = {
    enable = true;
  };

  services.radarr = {
    enable = true;
  };

  services.transmission = {
    enable = true;
    settings = {
      download-dir = "/nfs/samsung4tb/Content/Downloads";
      webHome = pkgs.flood;
    };
  };
}
