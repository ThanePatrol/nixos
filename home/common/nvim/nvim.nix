{
  inputs,
  pkgs,
  lib,
  theme,
  ...
}:
let
  fyler = pkgs.vimUtils.buildVimPlugin {
    name = "fyler-nvim";
    src = pkgs.fetchFromGitHub {
      owner = "A7Lavinraj";
      repo = "fyler.nvim";
      rev = "5c4e10511fe8117ac9832c2b1b5d5017355552c5";
      hash = "sha256-MByXyTX0ucCg9MDSBIs1J/15uVrcvL6x6ouy1d54Md4=";
    };
  };
in
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

      # icons!
      nvim-web-devicons

      # colour preview in editor
      nvim-highlight-colors

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

      # lsp helper, sets up root_dir, on_attach and other niceties
      nvim-lspconfig

      codecompanion-nvim

      #snippets
      luasnip
      cmp_luasnip

      # Colorschemes
      catppuccin-nvim

      # Renders markdown nicely
      render-markdown-nvim

      # Tree view with editable buffer
      fyler
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

      # provides many packages, including clangd
      llvmPackages_21.clang-unwrapped
    ];
  };
  xdg.configFile.nvim = {
    source = ./config;
    recursive = true;
  };
}
