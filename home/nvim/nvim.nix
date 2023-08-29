{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };
  # todo - make this more like https://github.com/fmoda3/nix-configs/tree/master/home/nvim/config/lua
  # less reliant on hard paths: also: <Right>https://www.reddit.com/r/NixOS/comments/xa30jq/homemanager_nvim_lua_config_for_plugins/
  xdg.configFile.nvim = {
    source = /home/hugh/.config/nvim;
    recursive = true;
  };
}
