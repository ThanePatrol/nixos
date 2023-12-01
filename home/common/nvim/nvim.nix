{ pkgs, lib, ... }:
with lib;
let
  #python-debug = pkgs.python3.withPackages (p: with p; [debugpy]);
in {

  # todo:
  # consider moving file tree to https://github.com/nvim-neo-tree/neo-tree.nvim
  # to take advantage of https://github.com/miversen33/netman.nvim

  # taken from https://github.com/fmoda3/nix-configs/tree/master/home/nvim
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    plugins = with pkgs.vimPlugins; [
      #General
      vim-sensible

      # Language specifics
      vim-nix
      kotlin-vim

      # File stuff
      nvim-tree-lua

      #emment syntax
      emmet-vim

      #autoclose
      nvim-autopairs

      #awesome file search
      telescope-nvim

      #indent lines
      indent-blankline-nvim

      # allow movement between tmux panes
      vim-tmux-navigator

      #rainbow brackets
      nvim-ts-rainbow

      #LSP
      nvim-lspconfig
      nvim-lsp-ts-utils

      #debugger
      nvim-dap
      nvim-dap-virtual-text 
      nvim-dap-go
      nvim-dap-ui
      #nvim-dap-python

      #Note taking
      neorg

      #Co pilot
      copilot-lua
      copilot-cmp

      #keybinds
      legendary-nvim

      #status bar
      lualine-nvim

      #show git changes in gutter
      vim-gitgutter

      #syntax highlighting
      nvim-treesitter.withAllGrammars

      #Completions
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      cmp-nvim-lsp-signature-help
      nvim-cmp
      lspkind-nvim

      #rust
      rust-vim
      rust-tools-nvim

      #c/c++
      #clangd_extensions-nvim      
      vim-ccls

      #scala
      nvim-metals
      #snippets
      luasnip
      cmp_luasnip

      catppuccin-nvim
    ];

    extraPackages = with pkgs; [
      tree-sitter
      #Language servers
      nodePackages.bash-language-server
      lua-language-server

      # todo - figure out why clangd isn't working
      #c/c++
      libclang
      libcxx
      cmake
      ccls
      #nix
      nil
      nixpkgs-fmt
      #python
      pyright
      #python311Packages.debugpy
      #       python-debug
      black
      #typescript/web
      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted
      nodejs_20
      typescript
      #rust
      rust-analyzer
      rustfmt
      rustc
      #scala
      metals

      # generic sql
      postgres-lsp

      terraform-ls

      # go
      gopls

      #latex
      texlab
    ];
  };
  xdg.configFile.nvim = {
    source = ./config;
    recursive = true;
  };
}
