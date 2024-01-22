{ isDarwin, pkgs, ... }:

let
  copyToClipboard = {
    fin = if isDarwin then
      ""
      #''bind-key -t vi-copy MouseDragEnd1Pane copy-pipe "pbcopy"''
    else
      "";
  }.fin;

in {
  home.packages = [ pkgs.tmux ];

  programs.tmux = {
    terminal = "tmux-256color";
    enable = true;
    mouse = true;
    shortcut = "a";
    baseIndex = 1;
    historyLimit = 20000;
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

      # fixes colors inside neovim
      set -ga terminal-overrides ",*256col*:Tc"

      # copy to clipboard
      ${copyToClipboard}

      # theming and font fixing
      set -g @catppuccin_no_patched_fonts_theme_enabled on
      set -g @catppuccin_date_time "%Y-%m-%d %H:%M"      

      # launch new pane in current dir
      bind '"' split-window -v -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"
    '';
  };

}
