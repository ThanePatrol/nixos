{ pkgs, ... }:

{
  systemd.services.blog-site = {
    description = "Serve Hugo site";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      DynamicUser = true;
      SupplementaryGroups = [ "bloggers" ];
      WorkingDirectory = "/var/www/html/blog/public";
      ExecStart = "${pkgs.python3}/bin/python3 -m http.server 1313";
      Restart = "always";
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = true;
    };
  };
}
