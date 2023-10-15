{ config, lib, pkgs,... }:

let 
  alacritty = import ./alacritty.nix;
  btop = import ./btop.nix;
  rclone = import ./rclone.nix;
  theme = import ./gtk_themes.nix;
  fonts = import ./fonts.nix;
  ssh = import ./ssh.nix;
  shell = import ./shell/shell.nix;
  git = import ./git.nix;
  neovim = import ./nvim/nvim.nix;
  tmux = import ./tmux.nix;
  hyprland = import ./hyprland/hyprland.nix;
  dunst = import ./dunst/dunst.nix;
  waybar = import ./waybar/waybar.nix;
  wofi = import ./wofi/wofi.nix;
  wayland = import ./wayland/wayland.nix;
  walls = import ./walls/wpapred.nix;
  desktop = import ./xdg/xdg.nix;
  rust = import ./rust.nix;
  xdg = import ./xdg/xdg.nix;
  zathura = import ./zathura.nix;
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
    waybar
    wofi
    wayland
    walls
    desktop
    rust
    xdg
    zathura
  ];

}
