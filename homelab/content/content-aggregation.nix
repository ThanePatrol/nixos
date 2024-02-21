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
    openRPCPort = true;
    settings = {
      download-dir = "/nfs/samsung4tb/Content/Downloads";
      rpc-bind-address = "127.0.0.1,10.0.0.*";
      rpc-whitelist = "127.0.0.1,10.0.0.*";
    };
    webHome = pkgs.flood-for-transmission;
  };
}
