{pkgs, ...}:

{

  services.sonarr = {
    enable = true;
    dataDir = "$HOME/.config";
  };

  services.radarr = {
    enable = true;
    dataDir = "$HOME/.config";
  };

  services.transmission = {
    enable = true;
    home = "$HOME/.config";
    settings = {
      download-dir = "/nfs/samsung4tb/Content/Downloads";
      webHome = pkgs.flood;
    };
  };
}
