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

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        AddKeysToAgent = "yes";
        IdentityFile = "~/.ssh/id_ed25519";
        User = "iw";
        SetEnv = {
          TERM = "xterm-256color";
        };
      };
    };
  };
  services.ssh-agent.enable = true;

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "https";
      version = 1;
    };
    gitCredentialHelper = {
      enable = true;
      hosts = [ "https://github.com" ];
    };
  };

  programs.diff-so-fancy = {
    enable = true;
    enableGitIntegration = true;
    settings = {
      stripLeadingSymbols = false;
    };
  };

  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "main";
      user.name = "westo0852";
      user.email = "iweston1702@gmail.com";
      core.editor = "nvim";
      # core.pager = diff-so-fancy | less --tabs=4 -RF
      pull.rebase = true;
      commit.verbose = true;
      stash.showPatch = true;
      push.autoSetupRemote = true;
    };

    ignores = [
      # keep-sorted start
      "!.env.example"
      "!.gitignore"
      "!README.md"
      "!gradle-wrapper.jar"
      "*.bak"
      "*.class"
      "*.crt"
      "*.db"
      "*.dll"
      "*.exe"
      "*.jar"
      "*.key"
      "*.log"
      "*.mov"
      "*.mp4"
      "*.out"
      "*.pdb"
      "*.pdf"
      "*.pem"
      ".DS_Store"
      ".build/"
      ".cache/"
      ".classpath"
      ".claude/"
      ".env"
      ".eslintcache"
      ".github/"
      ".gradle"
      ".gradle/"
      ".idea/"
      ".pytest_cache/"
      ".python-version"
      ".venv/"
      "__pycache__/"
      "bin/"
      "build/"
      "dist/"
      "logs/"
      "out.*"
      "out/"
      "public/"
      "target/"
      "temp.*"
      "temp/"
      "tmp/"
      # keep-sorted end
    ];
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
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
    initContent = ''
      setopt histignorealldups sharehistory inc_append_history interactive_comments
      bindkey '^F' history-incremental-search-forward
      export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent"
      source "$HOME/dotfiles/shell/.aliases"
      source "$HOME/dotfiles/shell/.p10k.zsh"
      source "${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
      eval "$(${pkgs.fzf}/bin/fzf --zsh)"
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
      
      # Do not ask confirmation to kill pane
      bind-key x kill-pane
      
      # Copy highlighted content once drag finishes
      bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel
      
      # Make it pretty
      set -g @catppuccin_flavor "mocha" # light="latte" dark="mocha"
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

      nvim-web-devicons
      mini-icons
      mini-nvim

      which-key-nvim
      fyler-nvim
      render-markdown-nvim

      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      luasnip
      cmp_luasnip

      conform-nvim
      nvim-jdtls
      vim-dadbod
      vim-dadbod-completion
      vim-dadbod-ui
    ];
    extraPackages = with pkgs; [
      tree-sitter
      gcc

      pyright
      gopls
      rust-analyzer
      jdt-language-server
      kotlin-language-server
      typescript-language-server
      bash-language-server
      lua-language-server

      shellcheck
      shfmt
      python3Packages.ruff
      gofumpt
      gotools
      stylua
      clang-tools
      google-java-format
    ];
  };

  xdg.configFile.nvim = {
    source = ./nvim;
    recursive = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
    config = {
      log_filter = "^$";
    };
  };
}
