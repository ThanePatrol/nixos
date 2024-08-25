{ pkgs, lib, theme, ... }:
with lib;
let
  # TODO - upstream
  thrift-ls = pkgs.buildGoModule rec {
    pname = "thriftls";
    version = "0.2.0";

    src = pkgs.fetchFromGitHub {
      owner = "joyme123";
      repo = pname;
      rev = "v${version}";
      sha256 = "sha256-Qib/xbTQiR0VpHsCOt5HGkbytaQ0GSCqaHVYFNPYGVs=";

    };

    vendorHash = "sha256-YoZ2dku84065Ygh9XU6dOwmCkuwX0r8a0Oo8c1HPsS4=";

    postInstall = ''
      mv $out/bin/thrift-ls $out/bin/thriftls
    '';

    meta = with lib; {
      description = "A thrift language server";
      homepage = "https://github.com/joyme123/thrift-ls";
      #license = licenses.apache2;
      #maintainers = with maintainers; [ meain ];
    };
  };

  # llm plugin
  gp = pkgs.vimUtils.buildVimPlugin {
    pname = "gp.nvim";
    version = "3.8.0";
    src = pkgs.fetchFromGitHub {
      owner = "Robitx";
      repo = "gp.nvim";
      rev = "7cc35997581dbfcfa5ac022843e12c04d64c3250";
      sha256 = "";
    };
  };
in {
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

      # File stuff
      nvim-tree-lua

      # icons!
      nvim-web-devicons

      # cmd autosuggestions
      #precognition-nvim

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

      # allow movement between tmux panes
      vim-tmux-navigator

      #rainbow brackets
      rainbow-delimiters-nvim

      #LSP
      nvim-lspconfig

      # Quick fixes for issues in file
      trouble-nvim

      #debugger
      #      nvim-dap
      #      nvim-dap-virtual-text
      #      nvim-dap-go
      #      nvim-dap-ui

      #Co pilot
      #      copilot-lua
      #      copilot-cmp

      # LLM plugin
      # TODO - setup
      #gp

      # format on save
      formatter-nvim

      # Images in nvim
      #image-nvim

      #status bar
      lualine-nvim

      # ide-like git highlighting
      gitsigns-nvim

      #syntax highlighting
      nvim-treesitter.withAllGrammars

      #Completions
      cmp-nvim-lsp
      nvim-cmp

      # breadcrumbs in status bar
      nvim-navic

      #rust
      rust-vim
      rust-tools-nvim

      #typescript
      nvim-lsp-ts-utils

      #snippets
      luasnip
      cmp_luasnip

      catppuccin-nvim

      # browser render of markdown
      markdown-preview-nvim
      # Renders markdown nicely
      markview-nvim

      # for eww LSP
      yuck-vim
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

      thrift-ls

      # image support
      #     imagemagick

    ];
    #    extraLuaPackages = ps: [ ps.magick];
  };
  xdg.configFile.nvim = {
    source = ./config;
    recursive = true;
  };

  # set theme using `theme` variable
  xdg.configFile."nvim/lua/color-theme.lua".text = let
    # Expect theme to be string Catppuccin-mocha or similar
    themeString = builtins.replaceStrings [ "Catppuccin-" ] [ "" ] theme;
    configText = ''
      require('catppuccin').setup({
          flavour = 'PLACEHOLDER_THEME', -- latte, frappe, macchiato, mocha
          background = { -- :h background
              light = 'latte',
              dark = 'mocha',
          },
          transparent_background = false, -- disables setting the background color.
          show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
          term_colors = true, -- sets terminal colors (e.g. `g:terminal_color_0`)
          dim_inactive = {
              enabled = false, -- dims the background color of inactive window
              shade = 'dark',
              percentage = 0.15, -- percentage of the shade to apply to the inactive window
          },
          no_italic = false, -- Force no italic
          no_bold = false, -- Force no bold
          no_underline = false, -- Force no underline
          styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
              comments = { 'italic' }, -- Change the style of comments
              conditionals = { 'italic' },
              loops = {},
              functions = {},
              keywords = {},
              strings = {},
              variables = {},
              numbers = {},
              booleans = {},
              properties = {},
              types = {},
              operators = {},
          },
          color_overrides = {},
          custom_highlights = {},
          integrations = {
              cmp = true,
              gitsigns = true,
              nvimtree = true,
              treesitter = true,
              notify = false,
              mini = false,
              -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
          },
        })
    '';
  in builtins.replaceStrings [ "PLACEHOLDER_THEME" ] [ themeString ] configText;
}
