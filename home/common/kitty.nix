{ pkgs, ... }:
{
  programs.kitty = {
    enable = true;
    font = {
      # package = pkgs.miracode;
      # name = "Miracode";
      package = pkgs._0xproto;
      name = "0xProto";
      size = 12;
    };
    shellIntegration.enableZshIntegration = true;
    themeFile = "Catppuccin-Mocha";
    settings = {
      clipboard_control = "write-clipboard write-primary read-clipboard read-primary";
      hide_window_decorations = "titlebar-only";
      macos_hide_titlebar = "yes";
      macos_option_as_alt = "yes";
    };
  };
}
