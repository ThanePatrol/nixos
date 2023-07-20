{ pkgs, ... }:

{
  home.file."./ssh/config".text = ''
   # Config file to setting up hosts
   #
  
   # x370 proxmox
   Host x370
           Hostname 192.168.1.193
           User root
  
   # Lenovo proxmox
   Host pve
           Hostname 192.168.1.190
           User root
  
   # Rockpro 05
   Host rockpro05
           Hostname 10.0.0.15
           User hugh
  
   # Rockpro 04
   Host rockpro04
           Hostname 10.0.0.14
           User hugh
  
   # Rockpro 03
   Host rockpro03
           Hostname 10.0.0.13
           User hugh
  
   # Rockpro 02
   Host rockpro02
           Hostname 10.0.0.12
           User hugh
  
   # Rockpro 01
   Host rockpro01
           Hostname 10.0.0.11
           User hugh
  
   # Rockpro 00
   Host rockpro00
           Hostname 10.0.0.10
           User hugh
  
   # Magic Mirror
   Host mirror
           Hostname 10.0.0.30
           User pi
  '';
}
