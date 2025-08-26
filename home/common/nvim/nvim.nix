{
  inputs,
  pkgs,
  lib,
  theme,
  ...
}:
with lib;
let

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

      #LSP
      nvim-lspconfig

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
      # catppuccin-nvim
      everforest

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
      postgres-lsp

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

  # set theme using `theme` variable
  # xdg.configFile."nvim/lua/color-theme.lua".text =
  #   let
  #     # Expect theme to be string Catppuccin-mocha or similar
  #     themeString = builtins.replaceStrings [ "Catppuccin-" ] [ "" ] theme;
  #     configText = ''
  #       require('catppuccin').setup({
  #           flavour = 'PLACEHOLDER_THEME', -- latte, frappe, macchiato, mocha
  #           background = { -- :h background
  #               light = 'latte',
  #               dark = 'mocha',
  #           },
  #           transparent_background = false, -- disables setting the background color.
  #           show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
  #           term_colors = true, -- sets terminal colors (e.g. `g:terminal_color_0`)
  #           dim_inactive = {
  #               enabled = false, -- dims the background color of inactive window
  #               shade = 'dark',
  #               percentage = 0.15, -- percentage of the shade to apply to the inactive window
  #           },
  #           no_italic = false, -- Force no italic
  #           no_bold = false, -- Force no bold
  #           no_underline = false, -- Force no underline
  #           styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
  #               comments = { 'italic' }, -- Change the style of comments
  #               conditionals = { 'italic' },
  #               loops = {},
  #               functions = {},
  #               keywords = {},
  #               strings = {},
  #               variables = {},
  #               numbers = {},
  #               booleans = {},
  #               properties = {},
  #               types = {},
  #               operators = {},
  #           },
  #           color_overrides = {},
  #           custom_highlights = {},
  #           integrations = {
  #               cmp = true,
  #               gitsigns = true,
  #               nvimtree = true,
  #               treesitter = true,
  #               notify = false,
  #               mini = false,
  #               -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
  #           },
  #         })
  #     '';
  #   in
  #   builtins.replaceStrings [ "PLACEHOLDER_THEME" ] [ themeString ] configText;
}
