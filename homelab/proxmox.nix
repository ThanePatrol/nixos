{ pkgs, lib, ... }:
{
  services.proxmox-ve = {
    enable = true;
    ipAddress = "10.0.0.3";
    bridges = [ "vmbr0" ];
  };
  networking.bridges.vmbr0.interfaces = [ "ens18" ];
  networking.interfaces.vmbr0.useDHCP = lib.mkDefault true;

  # TODO: Remove once https://github.com/SaumonNet/proxmox-nixos/pull/213 is merged.
  services.openssh.settings.AcceptEnv = lib.mkForce [
    "LANG"
    "LC_*"
  ];
}
