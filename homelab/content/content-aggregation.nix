{pkgs, ...}:
# FIXME - take inputs to read these
{

  services.sonarr = {
    enable = true;
    openFirewall = true;
  };

  services.radarr = {
    enable = true;
    openFirewall = true;
  };

  services.transmission = {
    enable = true;
    openFirewall = true;
    settings = {
      download-dir = "/nfs/samsung4tb/Content/Downloads";
      webHome = pkgs.flood;
    };
  };
}
