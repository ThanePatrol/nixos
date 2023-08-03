{ pkgs, ... }:

{
  home.packages = [ pkgs.tmux ];

  programs.tmux = {
    terminal = "screen-256color";
    enable = true;
    mouse = true;
    shortcut = "a";
    baseIndex = 1;
    historyLimit = 5000;

    plugins = [
      pkgs.tmuxPlugins.sensible
      pkgs.tmuxPlugins.catppuccin
      pkgs.tmuxPlugins.yank

    ];
  };


}
