{
  isWork,
  isDarwin,
  inputs,
  pkgs,
  lib,
  theme,
  ...
}:
let
  unnest = pkgs.vimUtils.buildVimPlugin {
    name = "unnest.nvim";
    src = pkgs.fetchFromGitHub {
      owner = "brianhuster";
      repo = "unnest.nvim";
      rev = "e9e269134ad85eb45c4e1fa3654801be0d3641b7";
      hash = "sha256-KpwImU3sK8aHuOz88VE8mwZXc+PezlTpb6JnimQ9ZLM=";
    };
  };

  # use absolute paths - hack 😭
  telescopeCodesearch = pkgs.vimUtils.buildVimPlugin {
    pname = "telescope-codesearch";
    version = "1.0";
    src = builtins.path {
      path = "/usr/local/google/home/hmandalidis/nvim-plugins/telescope-codesearch.nvim";
      name = "telescope-codesearch";
    };
  };

  critique = pkgs.vimUtils.buildVimPlugin {
    pname = "critique-nvim";
    version = "1.0.2";
    src = builtins.path {
      path = "/usr/local/google/home/hmandalidis/nvim-plugins/critique-nvim";
      name = "critique-nvim";
    };
    # depends on pkgs for build
    nativeBuildInputs = [
      pkgs.vimPlugins.plenary-nvim
      pkgs.vimPlugins.telescope-nvim
    ];
  };

  workPlugins = [
    telescopeCodesearch
    critique
  ];

in
{
  programs.neovim = {
    enable = true;
    package = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withPython3 = false; # shut up eval warnings
    withRuby = false; # ditto ^

    plugins =
      with pkgs.vimPlugins;
      [
        # keep-sorted start
        # allow movement between tmux panes
        # Colorschemes
        # colour preview in editor
        # convenient testing
        # format on save
        # icons!
        # ide-like git highlighting
        # lsp helper, sets up root_dir, on_attach and other niceties
        # Quick fixes for issues in file
        # Renders markdown nicely
        # Tree view with editable buffer
        #add emoji!
        #awesome file search
        #Completions
        #General
        #indent lines
        #snippets
        #status bar
        #syntax highlighting
        catppuccin-nvim
        cmp-nvim-lsp
        cmp_luasnip
        codecompanion-nvim
        formatter-nvim
        fyler-nvim
        gitsigns-nvim
        harpoon2
        indent-blankline-nvim
        lualine-nvim
        luasnip
        nvim-cmp
        nvim-highlight-colors
        nvim-lspconfig
        nvim-treesitter.withAllGrammars
        nvim-web-devicons
        rainbow-delimiters-nvim
        render-markdown-nvim
        telescope-nvim
        telescope-symbols-nvim
        trouble-nvim
        unnest
        vim-sensible
        vim-test
        vim-tmux-navigator
        vim-tmux-navigator
        # keep-sorted end
      ]
      ++ (if !isDarwin && isWork then workPlugins else [ ]);

    extraPackages = with pkgs; [
      # keep-sorted start
      # generic sql
      # go
      # Markdown
      # provides many packages, including clangd
      # Rego policy files
      #Language servers
      #latex
      #nix
      #python
      #rust
      #terraform lsp
      #typescript/web
      bash-language-server
      black
      delve
      gopls
      llvmPackages_21.clang-unwrapped
      lua-language-server
      luajitPackages.lua-utils-nvim
      marksman
      nil
      postgres-language-server
      pyright
      regols
      rust-analyzer
      rustfmt
      terraform-ls
      texlab
      tree-sitter
      typescript-language-server
      vscode-langservers-extracted
      # keep-sorted end
    ];
  };
  xdg.configFile.nvim = {
    source = ./config;
    recursive = true;
  };
}
