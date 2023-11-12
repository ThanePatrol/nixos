{ lib, config, pkgs, ... }:

let

  isDarwin = pkgs.stdenv.hostPlatform.config == "aarch64-apple-darwin";
  isLinux = pkgs.stdenv.hostPlatform.isLinux;

  commonPkgs = import ./packages/shared.nix { inherit pkgs lib; };
  macPkgs = import ./packages/mac.nix { inherit pkgs; };
  linuxPkgs = import ./packages/linux.nix { inherit pkgs; };

  universal = [
    (import ./common/bat/bat.nix)
    (import ./common/btop.nix)
    (import ./common/rclone.nix)
    (import ./common/fonts.nix)
    (import ./common/ssh.nix)
    (import ./common/shell/shell.nix)
    (import ./common/git.nix)
    (import ./common/nvim/nvim.nix)
    (import ./common/tmux.nix)
    (import ./common/rust.nix)
    (import ./common/wezterm/wezterm.nix)
    (import ./common/zathura.nix)
  ];

  macSpecific = [
    (import ./macos/yabai/yabai.nix)
    (import ./macos/skhd/skhd.nix)
  ];
  linuxSpecific = [
    (import ./linux/gtk_themes.nix)
    (import ./linux/hyprland/hyprland.nix)
    (import ./linux/dunst/dunst.nix)
    (import ./linux/waybar/waybar.nix)
    (import ./linux/wofi/wofi.nix)
    (import ./linux/wayland/wayland.nix)
    (import ./linux/walls/wpapred.nix)
    (import ./linux/xdg/xdg.nix)
  ];
  finalImports = {
    fin = if isDarwin then
      universal ++ macSpecific
    else if isLinux then
      universal ++ linuxSpecific
    else
      universal;
  }.fin;

  finalPackages = commonPkgs.packages; #{
 #   fin = if isDarwin then
 #     commonPkgs.packages #++ macPkgs.packages
 #   else if isLinux then
 #     commonPkgs.packages ++ linuxPkgs.packages
 #   else
 #     commonPkgs.packages;
 # }.fin;

in {

  home.username = "hugh";

  home.homeDirectory = (if isDarwin then "/Users/hugh" else "/home/hugh");
  home.stateVersion = "23.05"; # Please read the comment before changing.
  programs.home-manager.enable = true;

  home.packages = finalPackages;

  imports = finalImports;
}
