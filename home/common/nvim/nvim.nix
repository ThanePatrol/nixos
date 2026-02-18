{
  isDarwin,
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

  linuxPlugins = [
  ];

in
{
  programs.neovim = {
    enable = true;
    package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    plugins =
      with pkgs.vimPlugins;

      [
        plenary-nvim

        #General
        vim-sensible

        # Language specifics
        vim-nix

        vim-tmux-navigator
        # lots of overhauls
        noice-nvim

        # icons!
        nvim-web-devicons

        # File stuff
        #nvim-tree-lua
        # icons!
        nvim-web-devicons

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

        # Quick fixes for issues in file
        trouble-nvim
        # allow movement between tmux panes
        vim-tmux-navigator

        #rainbow brackets
        rainbow-delimiters-nvim

        # Quick fixes for issues in file
        trouble-nvim

        # convenient testing
        vim-test

        harpoon2

        # format on save
        formatter-nvim
        # format on save
        formatter-nvim

        # lsp helper, sets up root_dir, on_attach and other niceties
        nvim-lspconfig

        codecompanion-nvim

        #status bar
        lualine-nvim
        # Colorschemes
        catppuccin-nvim
        everforest

        #snippets
        luasnip
        cmp_luasnip

        # ide-like git highlighting
        gitsigns-nvim

        # Renders markdown nicely
        render-markdown-nvim

        #syntax highlighting
        nvim-treesitter.withAllGrammars
        # https://discourse.nixos.org/t/adding-a-new-tree-sitter-parser-to-neovim/23693/2
        # (nvim-treesitter.withPlugins (
        #   _:
        #   ++ (
        #     if isDarwin then
        #       [ ]
        #     else
        #       [
        #         (pkgs.tree-sitter.buildGrammar {
        #           language = "just";
        #           version = "8af0aab";
        #           src = pkgs.fetchFromGitHub {
        #             owner = "IndianBoy42";
        #             repo = "tree-sitter-just";
        #             rev = "8af0aab79854aaf25b620a52c39485849922f766";
        #             sha256 = "sha256-hYKFidN3LHJg2NLM1EiJFki+0nqi1URnoLLPknUbFJY=";
        #           };
        #         })
        #       ]
        #   )
        # ))

        #Completions
        cmp-nvim-lsp
        nvim-cmp

        # Tree view with editable buffer
        fyler
        #snippets
        luasnip
        cmp_luasnip

        catppuccin-nvim

        # Renders markdown nicely
        render-markdown-nvim
      ]
      ++ (if isDarwin then [ ] else linuxPlugins);

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
