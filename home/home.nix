{ config, pkgs, ... }:

let

  isDarwin = builtins.currentSystem == "aarch64-darwin";
  isLinux = pkgs.stdenv.hostPlatform.isLinux;

  commonPkgs = import ./packages/shared.nix { inherit pkgs; };

  universal = [
    (import ./bat.nix)
    (import ./alacritty.nix)
    (import ./btop.nix)
    (import ./rclone.nix)
    (import ./fonts.nix)
    (import ./ssh.nix)
    (import ./shell/shell.nix)
    (import ./git.nix)
    (import ./nvim/nvim.nix)
    (import ./tmux.nix)
    (import ./rust.nix)
    (import ./zathura.nix)
  ];

  macSpecific = [
    (import ./yabai/yabai.nix)
    (import ./skhd/skhd.nix)

  ];
  linuxSpecific = [
    (import ./gtk_themes.nix)
    (import ./hyprland/hyprland.nix)
    (import ./dunst/dunst.nix)
    (import ./waybar/waybar.nix)
    (import ./wofi/wofi.nix)
    (import ./wayland/wayland.nix)
    (import ./walls/wpapred.nix)
    (import ./xdg/xdg.nix)
  ];
  finalImports = {
    fin = if isDarwin then
      universal ++ macSpecific
    else if isLinux then
      universal ++ linuxSpecific
    else
      universal;
    }.fin;

    finalPackages = {
      fin = if isDarwin then
        commonPkgs.packages 
      else if isLinux then
        commonPkgs 
      else
        commonPkgs;
    }.fin;

in {

  home.username = "hugh";

  home.homeDirectory = (if isDarwin then "/Users/hugh" else "/home/hugh");
  home.stateVersion = "23.05"; # Please read the comment before changing.
  programs.home-manager.enable = true;
  
  home.packages = finalPackages;


  imports = finalImports;
}
