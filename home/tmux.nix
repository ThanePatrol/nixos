{ pkgs, ... }:

{
  home.packages = [ pkgs.tmux ];

  programs.tmux = {
    terminal = "xterm-256color";
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

    ];
    
    extraConfig = ''
      bind h select-pane -L
      bind j select-pane -D 
      bind k select-pane -U
      bind l select-pane -R

      set -g @catppuccin_no_patched_fonts_theme_enabled on
      set -g @catppuccin_date_time "%Y-%m-%d %H:%M"      
            
    '';
  };


}
