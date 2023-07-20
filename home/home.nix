{ pkgs, ... }:

let 
  alacritty = import ./alacritty.nix { inherit pkgs; };
  btop = import ./btop.nix { inherit pkgs; };
  rclone = import ./rclone.nix { inherit pkgs; };
  theme = import ./gtk_themes.nix { inherit pkgs; };
  fonts = import ./fonts.nix { inherit pkgs; };
  ssh = import ./ssh.nix { inherit pkgs; };
  shell = import ./shell.nix { inherit pkgs; };
  git = import ./git.nix { inherit pkgs; };
in
{

  home.stateVersion = "23.05";
  home.packages = [ pkgs.httpie ];


  imports = [ alacritty btop rclone theme fonts ssh shell git];
}
