{
  inputs,
  pkgs,
  lib,
  theme,
  ...
}:
with lib;
let
  # llm plugin
  gp = pkgs.vimUtils.buildVimPlugin {
    pname = "gp.nvim";
    version = "3.9.0";
    src = pkgs.fetchFromGitHub {
      owner = "Robitx";
      repo = "gp.nvim";
      rev = "7cc35997581dbfcfa5ac022843e12c04d64c3250";
      sha256 = "sha256-88UcYToQO3GU5Zw+EMUAP2NBpxf+b2l/PBXahrSp7fE=";
    };

    meta = with lib; {
      description = "ChatGPT like sessions in Neovim";
      homepage = "https://github.com/Robitx/gp.nvim";
      license = licenses.mit;
      maintainers = with maintainers; [ hughmandalidis ];
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

      # Language specifics
      vim-nix

      # lots of overhauls
      noice-nvim

      # File stuff
      nvim-tree-lua

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

      # allow movement between tmux panes
      vim-tmux-navigator

      #rainbow brackets
      rainbow-delimiters-nvim

      #LSP
      nvim-lspconfig

      # Quick fixes for issues in file
      trouble-nvim

      # convenient testing
      vim-test

      harpoon2

      # LLM plugin
      gp

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

      # gpt integration
      avante-nvim

      #rust
      rust-vim
      rust-tools-nvim

      #snippets
      luasnip
      cmp_luasnip

      catppuccin-nvim

      # Renders markdown nicely
      render-markdown-nvim
    ];

    extraPackages = with pkgs; [
      tree-sitter

      # C/cpp
      # For clangd
      llvmPackages_19.clang-unwrapped
      cmake

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

      # Thrift lsp
      thrift-ls
    ];
  };
  xdg.configFile.nvim = {
    source = ./config;
    recursive = true;
  };

  # set theme using `theme` variable
  xdg.configFile."nvim/lua/color-theme.lua".text =
    let
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
    in
    builtins.replaceStrings [ "PLACEHOLDER_THEME" ] [ themeString ] configText;
}
