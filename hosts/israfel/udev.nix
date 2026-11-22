{ pkgs, ... }:

{
  users.groups.plugdev = { };

  services.udev.packages = [
    pkgs.nrf-udev
    (pkgs.runCommandLocal "probe-rs-udev-rules" { } ''
      mkdir -p $out/lib/udev/rules.d
      cp ${./69-probe-rs.rules} $out/lib/udev/rules.d/69-probe-rs.rules
    '')
  ];
}
