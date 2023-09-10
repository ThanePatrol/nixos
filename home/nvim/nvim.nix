{ pkgs, lib, ... }:
with lib;
let
  python-debug = pkgs.python3.withPackages (p: with p; [debugpy]);
in
  {
    # taken from https://github.com/fmoda3/nix-configs/tree/master/home/nvim
  programs.neovim = {
     #package = pkgs.neovim-nightly;
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

       #autoclose
       nvim-autopairs

       #rainbow brackets
       nvim-ts-rainbow

       #LSP
       nvim-lspconfig
       nvim-lsp-ts-utils

       #keybinds
       legendary-nvim

       #status bar
       lualine-nvim

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

       #formatting
       rust-vim
      
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
       llvmPackages_11.clang-unwrapped
       libclang
       libcxx
       cmake
       glibc
       gcc
       libstdcxx5
       llvmPackages_rocm.llvm
       binutils_nogold
       binutils
       llvmPackages_rocm.clang
       ccls
       #nix
       nil
       nixpkgs-fmt
       #python
       pyright
       python-debug
       black
       #typescript/web
       nodePackages.typescript-language-server
       nodePackages.vscode-langservers-extracted
       #rust
       rust-analyzer
       rustfmt
       #scala
       metals
     ];
   };
   xdg.configFile.nvim = {
     source = ./config;
     recursive = true;
   };

  # todo - make this more like https://github.com/fmoda3/nix-configs/tree/master/home/nvim/config/lua
  # less reliant on hard paths: also: <Right>https://www.reddit.com/r/NixOS/comments/xa30jq/homemanager_nvim_lua_config_for_plugins/
#  xdg.configFile.nvim = {
#    source = /home/hugh/.config/nvim;
#    recursive = true;
#  };
}
