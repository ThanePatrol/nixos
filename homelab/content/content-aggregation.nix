{ pkgs, ... }:
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

  #https://github.com/nzbget/nzbget/blob/master/nzbget.conf
  #services.nzbget = {
  #  enable = true;
  #  settings = {
  #    MainDir = "/nfs/samsung4tb/Content/Downloads";
  #  };
  #};

  services.sabnzbd = { enable = true; };

  services.transmission = {
    enable = true;
    openFirewall = true;
    openRPCPort = true;
    downloadDirPermissions = "757";
    settings = {
      download-dir = "/nfs/samsung4tb/Content/Transmission";
      incomplete-dir = "/nfs/samsung4tb/Content/Transmission";
      rpc-bind-address = "127.0.0.1,10.0.0.*";
      rpc-whitelist = "127.0.0.1,10.0.0.*";
      speed-limit-up-enabled = true;
      speed-limit-up = 300; # KBs per second
      speed-limit-down-enabled = true;
      speed-limit-down = 2000;
    };
    webHome = pkgs.flood-for-transmission;
  };
}
