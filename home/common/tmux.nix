{ isDarwin, theme, pkgs, ... }:

let
  copyToClipboard = {
    fin = if isDarwin then
      ""
      #''bind-key -t vi-copy MouseDragEnd1Pane copy-pipe "pbcopy"''
    else
      "";
  }.fin;

  themeString = builtins.replaceStrings [ "Catppuccin-" ] [ "" ] theme;

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

      # Vim bindings for copy mode
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      set-option -g renumber-windows on

      # set theme
      set-option -g @catppuccin_flavour '${themeString}'

      # fixes colors inside neovim
      set -ga terminal-overrides ",*256col*:Tc"

      # Enter search mode immediately
	  bind-key / copy-mode \; send-key ?

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
