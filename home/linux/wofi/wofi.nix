{ pkgs, lib, config, ... }:

{
  programs.wofi = {
    enable = true;
    settings = {
      location = "center";
      allow_markup = true;
      width = 250;
    };
  };

}
