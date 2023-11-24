{ nixpkgs, lib, config, pkgs, ... }:

let
  #isDarwin = pkgs.stdenv.hostPlatform.config == "aarch64-apple-darwin";
  #isLinux = pkgs.stdenv.hostPlatform.isLinux;
  isDarwin = true; # FIXME inherit isDarwin from caller

  username = if isDarwin then "hmandalidis" else "hugh";
  commonPkgs = import ./packages/shared.nix { inherit pkgs lib; };
  macPkgs = import ./packages/mac.nix { inherit pkgs; };
  linuxPkgs = import ./packages/linux.nix { inherit pkgs; };

  finalPackages = commonPkgs.packages; #{
 #   fin = if isDarwin then
 #     commonPkgs.packages #++ macPkgs.packages
 #   else if isLinux then
 #     commonPkgs.packages ++ linuxPkgs.packages
 #   else
 #     commonPkgs.packages;
 # }.fin;

in {

  home.username = "${username}";

  home.homeDirectory = (if isDarwin then "/Users/${username}" else "/home/${username}");
  home.stateVersion = "23.05"; # Please read the comment before changing.
  programs.home-manager.enable = true;

  home.packages = finalPackages;

  imports =  [
     ./common/bat/bat.nix
     ./common/btop.nix
     ./common/rclone.nix
     ./common/fonts.nix
     ./common/ssh.nix
     (import ./common/shell/shell.nix {inherit isDarwin pkgs lib;})
     ./common/git.nix
     ./common/nvim/nvim.nix
     (import ./common/tmux.nix {inherit isDarwin pkgs;})
     ./common/rust.nix
     ./common/spotify/spotify.nix
     ./common/wezterm/wezterm.nix
     ./common/zathura.nix
   ] ++ 
   (if isDarwin then [
    ./macos/yabai/yabai.nix
    ./macos/skhd/skhd.nix
  ] else [ 
    ./linux/gtk_themes.nix
    ./linux/hyprland/hyprland.nix
    ./linux/dunst/dunst.nix
    ./linux/waybar/waybar.nix
    ./linux/wofi/wofi.nix
    ./linux/wayland/wayland.nix
    ./linux/walls/wpapred.nix
    ./linux/xdg/xdg.nix
    ./linux/cursor.nix
  ]);
}
