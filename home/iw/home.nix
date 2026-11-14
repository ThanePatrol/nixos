{ pkgs, ... }:

let
  basic = with pkgs; [
    zsh-powerlevel10k
    stow
    gnumake
    ripgrep
    fzf
    gzip
    zip
    unzip
    jq
    jujutsu
    diff-so-fancy
    tree
  ];
  
  project = with pkgs; [
    hugo
  ];

in
{
  home.username = "iw";
  home.homeDirectory = "/home/iw";
  home.packages = basic ++ project;

  home.stateVersion = "23.05";
  news.display = "silent";

  programs.home-manager.enable = true;

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;

    # Source p10k.zsh for prompt and other zsh plugins
    plugins = [
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.zsh-syntax-highlighting;
      }
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      # {
      #   name = "powerlevel10k-config";
      #   src = ./.;
      #   file = "p10k.zsh";
      # }
    ];

    # Adapted from imperative .zshrc
    initContent = ''
      setopt histignorealldups sharehistory inc_append_history interactive_comments

      bindkey '^F' history-incremental-search-forward

      # TODO Add as needed other zsh config and shell variables like SSH_AUTH_SOCK

      source "$HOME/dotfiles/shell/.aliases"
      source "$HOME/dotfiles/shell/.p10k.zsh"
      source "${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
      eval "$(${pkgs.fzf}/bin/fzf --zsh)"
      # if [ ! -d "$HOME/.config/nvim" ]; then
      #   stow -d "$HOME/dotfiles" -t "$HOME" nvim
      # fi

      # export TERM=xterm-kitty
      if ! tmux list-sessions >/dev/null 2>&1; then
        tmux new -s dev
      fi
    '';
  };

  programs.tmux = {
    enable = true;
    mouse = true;
    terminal = "tmux-256color";
    shortcut = "space"; # set -g prefix C-space
    baseIndex = 1;
    keyMode = "vi";
    plugins = with pkgs.tmuxPlugins; [
      catppuccin
    ];
    extraConfig = ''
      # Open new pane to current dir
      bind  c  new-window      -c "#{pane_current_path}"
      bind  %  split-window -h -c "#{pane_current_path}"
      bind '"' split-window -v -c "#{pane_current_path}"
      
      # Use n and N for window navigation
      unbind p
      bind-key N previous-window
      
      # Copy highlighted content once drag finishes
      bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel
      
      set -g @catppuccin_flavor "mocha" # light="latte" dark="mocha"
      
      # Pretty status bar
      set -g status-left ""
      set -g status-right "#[fg=#{@thm_crust},bg=#{@thm_teal}] #S #[fg=#{@thm_crust},bg=#{@thm_mauve}] %k:%M %d-%m-%y "
      set -g status-right-length 100
      
      set -g window-status-format "#[fg=#{@thm_crust},bg=#{@thm_text}] #I #[default] #[fg=#{@thm_text},bold]#{b:pane_current_path}"
      set -g window-status-current-format "#[fg=#{@thm_crust},bg=#{@thm_flamingo}] #I #[default] #[fg=#{@thm_rosewater},bold]#{b:pane_current_path}"
      set -g window-status-current-style "nounderscore"
    '';
  };

  programs.neovim = {
    enable = true;
    withPython3 = false;
    withRuby = false;
    plugins = with pkgs.vimPlugins; [

      plenary-nvim
      telescope-nvim
      nvim-treesitter.withAllGrammars

      gitsigns-nvim
      nightfox-nvim

      mini-icons

      nvim-web-devicons
      mini-nvim
      which-key-nvim

      # Full list:
      # LuaSnip
      # PDFview
      # cmp-buffer
      # cmp-nvim-lsp
      # cmp-path
      # cmp_luasnip
      # conform.nvim
      # fyler.nvim
      # gitsigns.nvim
      # mini-icons
      # mini.nvim
      # nightfox.nvim
      # nvim-cmp
      # nvim-jdtls
      # nvim-lspconfig
      # plenary.nvim
      # render-markdown.nvim
      # telescope.nvim
      # vim-dadbod
      # vim-dadbod-completion
      # vim-dadbod-ui
      # which-key.nvim
    ];
    extraPackages = with pkgs; [
      lua-language-server
      shellcheck
      gcc
      tree-sitter
    ];
  };

  xdg.configFile.nvim = {
    source = ./nvim;
    recursive = true;
  };
}
