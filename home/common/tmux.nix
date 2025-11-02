{
  isDarwin,
  theme,
  pkgs,
  ...
}:

let
  themeString = builtins.replaceStrings [ "Catppuccin-" ] [ "" ] theme;

  getLastThreeDirs = pkgs.writeShellScriptBin "get-last-three-dirs" ''
    last_three="$(awk '{split($0,arr,"/"); print arr[length(arr)-2],arr[length(arr)-1],arr[length(arr)]}' | tr ' ' '/')"
    echo $last_three
  '';

in
{
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
      pkgs.tmuxPlugins.catppuccin
      pkgs.tmuxPlugins.vim-tmux-navigator
    ];

    extraConfig = ''
      bind-key & kill-window
      bind-key x kill-pane

      set-option -g renumber-windows on
      # CRL + Shift + key to left/right a window
      bind-key -n C-S-h previous-window
      bind-key -n C-S-l next-window

      # allow apps inside tmux to set clipboard
      set -gs set-clipboard on
      set -as terminal-features ',xterm-256color:clipboard'


      # fixes colors inside neovim
      set -ga terminal-overrides ",*256col*:Tc"

      # Enter search mode immediately
      bind-key / copy-mode \; send-key ?

      # copy highlighted content when drag finished
      bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel

      # Images
      set -gwsq allow-passthrough on

      # set theme
      set-option -g @catppuccin_flavor '${themeString}'
      # theming and font fixing
      set -g @catppuccin_no_patched_fonts_theme_enabled on
      set -g @catppuccin_date_time "%Y-%m-%d %H:%M"

      # Set right status bar
      set -g status-right ""
      set -ag status-right "#{E:@catppuccin_status_application}"
      set -ag status-right "#{E:@catppuccin_status_session}"
      set -ag status-right "#{E:@catppuccin_status_date_time}"
      set -g status-right-length 100

      # Set window names
      set -g status-left ""
      set -g window-status-current-format "#[fg=#11111b,bg=#{@thm_mauve}] #I #[fg=#cdd6f4,bg=#{@thm_surface_1}] #(echo #{pane_current_path} | ${getLastThreeDirs}/bin/get-last-three-dirs) "
      set -g window-status-format "#[fg=#11111b,bg=#{@thm_overlay_2}] #I #[fg=#cdd6f4,bg=#{@thm_surface_0}] #(echo #{pane_current_path} | ${getLastThreeDirs}/bin/get-last-three-dirs) "

      # launch new pane in current dir
      bind '"' split-window -v -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"

      # set default shell to zsh instead of sh https://github.com/tmux/tmux/issues/4166
      set -g default-command '$SHELL'
    '';
  };

}
