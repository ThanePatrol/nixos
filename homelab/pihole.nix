{
  pkgs,
  ports,
  ...
}:
{
  services.pihole-ftl = {
    enable = true;
    openFirewallDNS = true;
  };

  services.pihole-web = {
    enable = true;
    ports = [ "${builtins.toString ports.openFirewall.pihole}" ];
  };
}
