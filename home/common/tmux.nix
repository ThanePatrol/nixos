{
  isDarwin,
  theme,
  pkgs,
  ...
}:

let
  themeString = builtins.replaceStrings [ "Catppuccin-" ] [ "" ] theme;

  tmuxPopupShell = pkgs.writeShellScriptBin "tmux-popup" ''
    tmux popup -E "tmux attach -t popup || tmux new -s popup"
    exit 0
  '';

  tmuxClosePopup = pkgs.writeShellScriptBin "close-tmux-popup" ''
    session_name=$(tmux display-message -p '#S')
    if [[ "$session_name" == "popup" ]]; then
      tmux detach-client -s popup
      exit 0
    else
      tmux send-keys Escape
    fi
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

      # popup a shell session and close it
      bind-key j run-shell '${tmuxPopupShell}/bin/tmux-popup'
      bind-key -T root Escape run-shell '${tmuxClosePopup}/bin/close-tmux-popup'
      bind-key -T copy-mode Escape run-shell '${tmuxClosePopup}/bin/close-tmux-popup'
      bind-key -T copy-mode-vi Escape run-shell '${tmuxClosePopup}/bin/close-tmux-popup'

      # allow apps inside tmux to set clipboard
      set -s set-clipboard on
      set -as terminal-features ',xterm-256color:clipboard'
      set -s copy-command "${if isDarwin then "reattach-to-user-namespace pbcopy" else "wl-copy"}"

      # Copy mode stuff
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel
      bind-key -T copy-mode-vi Y send-keys -X copy-pipe
      bind-key -T copy-mode y send-keys -X copy-pipe-and-cancel
      bind-key -T copy-mode Y send-keys -X copy-pipe

      set-option -g renumber-windows on

      # set theme
      set-option -g @catppuccin_flavour '${themeString}'

      # fixes colors inside neovim
      set -ga terminal-overrides ",*256col*:Tc"

      # Enter search mode immediately
      bind-key / copy-mode \; send-key ?

      # Images
      set -g allow-passthrough on

      # theming and font fixing
      set -g @catppuccin_no_patched_fonts_theme_enabled on
      set -g @catppuccin_date_time "%Y-%m-%d %H:%M"
      set -g @catppuccin_status_modules_right "application session date_time"
      #set -g @catppuccin_status_left_separator "█"
      #set -g @catppuccin_status_right_separator " "

      # launch new pane in current dir
      bind '"' split-window -v -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"

      # set default shell to zsh instead of sh https://github.com/tmux/tmux/issues/4166
      set -g default-command '$SHELL'
    '';
  };

}
