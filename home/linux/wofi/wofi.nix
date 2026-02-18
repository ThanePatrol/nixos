{
  pkgs,
  lib,
  config,
  ...
}:

let
  styleSheet = builtins.readFile ./style.css;
in
{
  programs.wofi = {
    enable = true;
    settings = {
      allow_images = true;

      style = builtins.toFile "style.css" styleSheet;
      location = "center";
      allow_markup = true;
      width = 250;
    };
  };

}
