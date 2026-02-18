{ pkgs, ... }:

{
  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    hyprcursor.enable = true;
    package = pkgs.phinger-cursors;
    size = 32;
    name = "phinger-cursors-dark";
  };
}
