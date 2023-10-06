{ pkgs, ... }:

{
  home.packages = [ pkgs.tmux ];

  programs.tmux = {
    #terminal = "tmux-256color";
    enable = true;
    mouse = true;
    shortcut = "a";
    baseIndex = 1;
    historyLimit = 5000;
    keyMode = "vi";

    plugins = [
      pkgs.tmuxPlugins.sensible
      pkgs.tmuxPlugins.catppuccin
      pkgs.tmuxPlugins.yank
      pkgs.tmuxPlugins.vim-tmux-navigator
    ];
    
    extraConfig = ''
      bind-key & kill-window
      bind-key x kill-pane

      set-option -g renumber-windows on

      # fixes colors
      set-option -sa terminal-overrides ",xterm*:Tc"

      set -g @catppuccin_no_patched_fonts_theme_enabled on
      set -g @catppuccin_date_time "%Y-%m-%d %H:%M"      
    '';
  };


}
