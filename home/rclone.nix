{ pkgs, ... }:

{
  home.packages = [ pkgs.rclone ];
  
  #todo - configure local backups and remote backups
  # get prompting for local
  home.file."./.config/rclone/rclone.conf".text = ''
    [seafile_to_NAS]
    type = local
    
    [b2-01]
    type = b2
    account = 004736e907299a10000000002
    
    [b2-ironwolfs]
    type = b2
    account = 004736e907299a10000000003
    hard_delete = true
  '';
}
