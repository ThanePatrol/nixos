{ pkgs, ... }:

{
  programs.zsh.enable = true;
  users.users.hugh.shell = pkgs.zsh;
  environment.shells = with pkgs; [ zsh ] ;
}
