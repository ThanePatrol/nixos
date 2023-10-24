{ pkgs, ... }:

{
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    nerdfonts
    #(nerdfonts.override {
    #  fonts = [ "JetBrainsMono" "FiraCode" "DroidSansMono" "Noto" ];
    #})
    source-han-code-jp
    source-han-sans
    source-han-mono
    source-han-serif
    roboto-mono
  ];
}
