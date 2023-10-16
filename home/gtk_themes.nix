{ pkgs, ... }:

{
  home.packages = with pkgs; [

    materia-kde-theme
    libsForQt5.qtstyleplugin-kvantum
  ];

  gtk.enable = true;

  gtk.iconTheme.package = pkgs.papirus-icon-theme;
  gtk.iconTheme.name = "Papirus-Dark";

  gtk.theme.package = pkgs.materia-theme;
  gtk.theme.name = "Materia-dark-compact";

}

