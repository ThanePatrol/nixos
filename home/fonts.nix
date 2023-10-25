{ pkgs, ... }:

{
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    nerdfonts
    source-han-code-jp
    source-han-sans
    source-han-mono
    source-han-serif
    roboto-mono
  ];
}
