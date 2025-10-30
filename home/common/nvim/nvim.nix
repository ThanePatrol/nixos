{
  inputs,
  pkgs,
  lib,
  theme,
  ...
}:
{
  programs.neovim = {
    enable = true;
    package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    plugins = with pkgs.vimPlugins; [
      #General
      vim-sensible

      vim-tmux-navigator

      # notifications!
      nvim-notify

      # icons!
      nvim-web-devicons

      # colour preview in editor
      nvim-highlight-colors

      #autoclose
      nvim-autopairs

      #awesome file search
      telescope-nvim

      #add emoji!
      telescope-symbols-nvim

      #indent lines
      indent-blankline-nvim

      #rainbow brackets
      rainbow-delimiters-nvim

      # Quick fixes for issues in file
      trouble-nvim

      harpoon2

      # format on save
      formatter-nvim

      #status bar
      lualine-nvim

      # ide-like git highlighting
      gitsigns-nvim

      #syntax highlighting
      nvim-treesitter.withAllGrammars

      #Completions
      cmp-nvim-lsp
      nvim-cmp

      codecompanion-nvim

      #snippets
      luasnip
      cmp_luasnip

      # Colorschemes
      catppuccin-nvim

      # Renders markdown nicely
      render-markdown-nvim
    ];

    extraPackages = with pkgs; [
      tree-sitter

      #Language servers
      bash-language-server
      lua-language-server

      luajitPackages.lua-utils-nvim

      #nix
      nil

      #python
      pyright
      black

      #typescript/web
      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted

      #rust
      rust-analyzer
      rustfmt

      # generic sql
      postgres-language-server

      #terraform lsp
      terraform-ls

      # go
      gopls
      delve

      #latex
      texlab

      # Markdown
      marksman
    ];
  };
  xdg.configFile.nvim = {
    source = ./config;
    recursive = true;
  };
}
