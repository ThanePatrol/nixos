{ pkgs, ... }:
{
  programs.kitty = {
    enable = true;
    package = null; # use apt version
    font = {
      package = pkgs.nerd-fonts.jetbrains-mono;
      name = "JetbrainsMono Nerd Font";
      size = 12;
    };
    shellIntegration.enableZshIntegration = true;
    themeFile = "Catppuccin-Mocha";
    settings = {
      clipboard_control = "write-clipboard write-primary read-clipboard read-primary";
    };

  };
}
