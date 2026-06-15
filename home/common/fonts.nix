{ pkgs, ... }:

{
  fonts.fontconfig = {

    enable = true;
    antialiasing = true;
    subpixelRendering = "rgb";
  };

  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    miracode
    monocraft

    nerd-fonts.roboto-mono
    nerd-fonts.inconsolata
  ];
}
