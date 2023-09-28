
{ pkgs, lib, ...}:

let 
  wallsDir = ./pics;
  saveDir = "./.config/wpaperd/walls";
in
{
  home.file = lib.mkMerge [
    { 
    "./.config/wpaperd/wallpaper.toml".text = ''
      [default]
      path = "~/.config/wpaperd/walls"
      duration = "1m"
      '';
    }
    (lib.mapAttrs' (name: _: {
      name = "${saveDir}/${name}";
      value = { source = "${wallsDir}/${name}"; };
    }) (builtins.readDir "${wallsDir}"))

  ]; 

}
