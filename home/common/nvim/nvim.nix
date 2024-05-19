{ pkgs, lib, theme, ... }:
with lib;
let
  #python-debug = pkgs.python3.withPackages (p: with p; [debugpy]);
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
      kotlin-vim

      # File stuff
      nvim-tree-lua

      #emment syntax
      emmet-vim

      # icons!
      nvim-web-devicons

      # colour preview in editor
      nvim-highlight-colors

      #autoclose
      nvim-autopairs

      # java
      nvim-jdtls

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

      # browser render of markdown
      markdown-preview-nvim

      # for eww LSP
      yuck-vim
    ];

    extraPackages = with pkgs; [
      tree-sitter
      #Language servers
      nodePackages.bash-language-server
      lua-language-server

      luajitPackages.lua-utils-nvim

      # todo - figure out why clangd isn't working
      #c/c++
      libclang
      libcxx
      cmake
      ccls
      #nix
      nil
      nixpkgs-fmt

      # kotlin
      kotlin-language-server

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

      #opengl lsp

      # generic sql
      postgres-lsp

      #terraform lsp
      terraform-ls

      #java
      jdt-language-server
      jdk17

      # go
      gopls
      delve

      #latex
      texlab
    ];
  };
  xdg.configFile.nvim = {
    source = ./config;
    recursive = true;
  };

  xdg.configFile."nvim/lua/java.lua".text = ''
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "java",
      callback = function()
        local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
        -- vim.lsp.set_log_level('DEBUG')
        -- local workspace_dir = "/home/jake/.workspace/" .. project_name 
        local config = {
          cmd = {'${pkgs.jdt-language-server}/bin/jdtls'},
        }
        require("jdtls").start_or_attach(config)
      end,
    })
  '';

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
