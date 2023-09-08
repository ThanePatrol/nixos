{ pkgs, config, lib, ... }:
with lib;
let
  python-debug = pkgs.python3.withPackages (p: with p; [debugpy]);
in
{
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
       #nix
       nil
       nixpkgs-fmt
       #python
       pyright
       python-debug
       black
       #typescript
       nodePackages.typescript-language-server
       #rust
       rust-analyzer
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
