{
  systemd.services.docker.wantedBy = [ "multi-user.target" ];
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };
}
