{ pkgs, ... }:

{
  home.packages = [ pkgs.rclone ];
  
  home.file."./.config/rclone/rclone.conf".text = ''
    [seafile_to_NAS]
    type = local
    
    [b2-01]
    type = b2
    account = 004736e907299a10000000002
    key = K004SX2qOXUYf3DX6hQqNRXPTeWFOEY
    
    [b2-ironwolfs]
    type = b2
    account = 004736e907299a10000000003
    key = K0046BsA1Bt+S4OYOB29yuYt9IVxFik
    hard_delete = true
  '';
}
