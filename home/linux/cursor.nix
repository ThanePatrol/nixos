{ pkgs, ... }:

{
  home.pointerCursor = {
    package = pkgs.apple-cursor;
    size = 32;
    name = "macOS-BigSur";

  };
}
