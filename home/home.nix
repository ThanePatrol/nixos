{ config, pkgs, ... }:

let 
  alacritty = import ./alacritty.nix;
  btop = import ./btop.nix;
  rclone = import ./rclone.nix;
  theme = import ./gtk_themes.nix;
  fonts = import ./fonts.nix;
  ssh = import ./ssh.nix;
  shell = import ./shell.nix;
  git = import ./git.nix;
  neovim = import ./nvim/nvim.nix;
  tmux = import ./tmux.nix;
  hyprland = import ./hyprland/hyprland.nix;
  dunst = import ./dunst/dunst.nix;
in
{
  home.stateVersion = "23.05";
  home.packages = [ pkgs.httpie ];

  imports = [
    alacritty
    btop
    rclone
    theme
    fonts
    ssh
    shell
    git
    neovim
    tmux
    hyprland
    dunst
  ];
}
