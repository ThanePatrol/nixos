{
  email,
  isWork,
  isDarwin,
  username,
  gitUserName,
  theme,
  lib,
  pkgs,
  ...
}:

let
  commonPkgs = import ./packages/shared.nix { inherit pkgs lib; };
  macPkgs = import ./packages/mac.nix { inherit pkgs; };
  linuxPkgs = import ./packages/linux.nix { inherit pkgs; };

  finalPackages =
    if isDarwin then
      commonPkgs.packages ++ macPkgs.packages
    else
      commonPkgs.packages ++ linuxPkgs.packages;

in
{
  home.username = "${username}";

  home.homeDirectory = (if isDarwin then "/Users/${username}" else "/home/${username}");
  home.stateVersion = "23.05"; # Please read the comment before changing.
  programs.home-manager.enable = true;

  home.packages = finalPackages;

  imports =
    [
      (import ./common/direnv.nix)
      (import ./common/bat/bat.nix { inherit theme; })
      (import ./common/btop/btop.nix { inherit theme pkgs; })
      ./common/rclone.nix
      ./common/fonts.nix
      (import ./common/ssh.nix { inherit gitUserName; })
      (import ./common/shell/shell.nix {
        inherit
          isWork
          isDarwin
          theme
          pkgs
          lib
          ;
      })
      (import ./common/git.nix { inherit email gitUserName theme; })
      (import ./common/nvim/nvim.nix { inherit pkgs lib theme; })
      (import ./common/tmux.nix { inherit isDarwin theme pkgs; })
      ./common/rust.nix
      ./common/spotify/spotify.nix
      (import ./common/wezterm/wezterm.nix { inherit pkgs theme; })
      (import ./common/zathura/zathura.nix { inherit theme; })
    ]
    ++ (
      if isDarwin then
        [
          #    ./macos/yabai/yabai.nix
          #    ./macos/skhd/skhd.nix
          ./macos/sketchybar/sketchy.nix
        ]
      else
        [
          ./linux/gtk_themes.nix
          ./linux/hyprland/hyprland.nix
          ./linux/dunst/dunst.nix
          ./linux/waybar/waybar.nix
          ./linux/wofi/wofi.nix
          ./linux/wayland/wayland.nix
          ./linux/walls/wpapred.nix
          ./linux/xdg/xdg.nix
          ./linux/cursor.nix
          ./linux/swaylock.nix
          ./linux/swayidle.nix
          ./linux/dconf.nix
          #  ./linux/eww/eww.nix
        ]
    );
}
