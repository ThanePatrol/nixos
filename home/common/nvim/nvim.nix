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

  rainbow-delimiter = pkgs.vimUtils.buildVimPlugin {
    name = "rainbow-delimiters.nvim";
    src = pkgs.fetchFromGitHub {
      owner = "HiPhish";
      repo = "rainbow-delimiters.nvim";
      rev = "607a438d8c647a355749973fd295e33505afafde";
      hash = "sha256-nqZKbqUeVkwzZlUR+xAKe4cb65DahWgStreRtGUchXE=";
    };
    nvimSkipModules = [
      # vim plugin with optional toggleterm integration
      "rainbow-delimiters.types"
      "rainbow-delimiters._test.highlight"
    ];
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
      # keep-sorted start
      # Colorschemes
      catppuccin-nvim
      #Completions
      cmp-nvim-lsp
      cmp_luasnip
      codecompanion-nvim
      # format on save
      formatter-nvim
      # Tree view with editable buffer
      fyler
      # ide-like git highlighting
      gitsigns-nvim
      harpoon2
      #indent lines
      indent-blankline-nvim
      #status bar
      lualine-nvim
      #snippets
      luasnip
      nvim-cmp
      # colour preview in editor
      nvim-highlight-colors
      # lsp helper, sets up root_dir, on_attach and other niceties
      nvim-lspconfig
      #syntax highlighting
      nvim-treesitter.withAllGrammars
      # icons!
      nvim-web-devicons
      rainbow-delimiter
      # Renders markdown nicely
      render-markdown-nvim
      #awesome file search
      telescope-nvim
      #add emoji!
      telescope-symbols-nvim
      # Quick fixes for issues in file
      trouble-nvim
      #General
      vim-sensible
      # convenient testing
      vim-test
      vim-tmux-navigator
      # allow movement between tmux panes
      vim-tmux-navigator
      # keep-sorted end
    ];

    extraPackages = with pkgs; [
      # keep-sorted start
      #Language servers
      bash-language-server
      black
      delve
      # go
      gopls
      # provides many packages, including clangd
      llvmPackages_21.clang-unwrapped
      lua-language-server
      luajitPackages.lua-utils-nvim
      # Markdown
      marksman
      #nix
      nil
      #typescript/web
      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted
      # generic sql
      postgres-language-server
      #python
      pyright
      # Rego policy files
      regols
      #rust
      rust-analyzer
      rustfmt
      #terraform lsp
      terraform-ls
      #latex
      texlab
      tree-sitter
      # keep-sorted end
    ];
  };
  xdg.configFile.nvim = {
    source = ./config;
    recursive = true;
  };
}
