{ config, pkgs, ... }:

let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  isLinux = pkgs.stdenv.hostPlatform.isLinux;

  universal = [
   #   (import ./alacritty.nix)
   #   (import ./btop.nix)
   #   (import ./rclone.nix)
   #   (import ./fonts.nix)
   #   (import ./ssh.nix)
   #   (import ./shell/shell.nix)
   #   (import ./git.nix)
   #   (import ./nvim/nvim.nix)
   #   (import ./tmux.nix)
   #   (import ./rust.nix)
   #   (import ./zathura.nix)
  ];

  macSpecific = [

  ];
  linuxSpecific = [
    #   (import ./gtk_themes.nix)
    #    (import ./hyprland/hyprland.nix)
    #    (import ./dunst/dunst.nix)
    #    (import ./waybar/waybar.nix)
    #    (import ./wofi/wofi.nix)
    #    (import ./wayland/wayland.nix)
    #    (import ./walls/wpapred.nix)
    #    (import ./xdg/xdg.nix)
  ];
in {

  home.username = "hugh";

  home.homeDirectory = (if isDarwin then "/Users/hugh" else "/home/hugh");
  home.stateVersion = "23.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

#  # Home Manager is pretty good at managing dotfiles. The primary way to manage
#  # plain files is through 'home.file'.
#  home.file = {
#    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
#    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
#    # # symlink to the Nix store copy.
#    # ".screenrc".source = dotfiles/screenrc;
#
#    # # You can also set the file content immediately.
#    # ".gradle/gradle.properties".text = ''
#    #   org.gradle.console=verbose
#    #   org.gradle.daemon.idletimeout=3600000
#    # '';
#  };

  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/hugh/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.
#  home.sessionVariables = {
#    # EDITOR = "emacs";
#  };

  # TODO - make this work on linux
  programs.home-manager.enable = true;


  #imports = universal ++ (if isDarwin then macSpecific else linuxSpecific);

}
