{
  inputs,
  email,
  isWork,
  isDarwin,
  username,
  gitUserName,
  theme,
  homeDirectory,
  minimal,
  lib,
  pkgs,
  ...
}:

let
  commonPkgs = import ./packages/shared.nix { inherit pkgs lib minimal; };
  macPkgs = import ./packages/mac.nix { inherit pkgs; };
  linuxPkgs = import ./packages/linux.nix { inherit pkgs; };

  finalPackages =
    if isDarwin then
      commonPkgs.packages ++ macPkgs.packages
    else if !minimal then
      commonPkgs.packages ++ linuxPkgs.packages
    else
      commonPkgs.packages;

in
{
  home.username = "${username}";

  home.homeDirectory = homeDirectory;
  home.stateVersion = "23.05"; # Please read the comment before changing.
  programs.home-manager.enable = true;
  news.display = "silent";

  home.packages = finalPackages;

  imports = [
    (import ./common/direnv.nix)
    (import ./common/bat/bat.nix { inherit theme; })
    (import ./common/btop/btop.nix { inherit theme pkgs; })
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
    (import ./common/nvim/nvim.nix {
      inherit
        isWork
        isDarwin
        inputs
        pkgs
        lib
        theme
        ;
    })
    (import ./common/tmux.nix { inherit isDarwin theme pkgs; })
    ./common/rust.nix
  ]
  ++ (
    if minimal then # Packages suitable for headless.
      [
      ]
    else
      (
        if isDarwin then
          [
          ]
        else
          [
            ./linux/gtk_themes.nix
            (import ./linux/hyprland/hyprland.nix { inherit isWork pkgs lib; })
            ./linux/dunst/dunst.nix
            ./linux/waybar/waybar.nix
            ./linux/wofi/wofi.nix
            ./linux/wayland/wayland.nix
            # ./linux/xdg/xdg.nix
            ./linux/cursor.nix
            ./linux/swaylock.nix
            ./linux/swayidle.nix
            ./linux/dconf.nix
            #  ./linux/eww/eww.nix
          ]
      )
      ++ [
        # Common packages not suitable for headless.
        ./common/fonts.nix
        ./common/spotify/spotify.nix
        ./common/kitty.nix
      ]
  )
  ++
    # hack to avoid loading in sops.nix files as we don't need them anywhere else.
    (
      # TODO - should probably define this elsewhere.
      if !isDarwin && !isWork then
        [
          ./common/rclone.nix
        ]
      else
        [ ]
    );
}
