{
  pkgs,
  ports,
  ...
}:
{
  nixpkgs.overlays = [
    (final: prev: {
      # TODO: Remove once https://github.com/NixOS/nixpkgs/pull/569464 is in.
      pihole-ftl = prev.pihole-ftl.overrideAttrs (old: {
        env = (old.env or { }) // {
          NIX_CFLAGS_COMPILE = toString [
            (old.env.NIX_CFLAGS_COMPILE or "")
            "-Wno-error=unused-but-set-variable"
          ];
        };
      });
    })
  ];

  services.pihole-ftl = {
    enable = true;
    openFirewallDNS = true;
  };

  services.pihole-web = {
    enable = true;
    ports = [ "${builtins.toString ports.openFirewall.pihole}" ];

  };
}
