{ pkgs, ... }:

let 
  alacritty = import ./alacritty.nix { inherit pkgs; };
  btop = import ./btop.nix { inherit pkgs; };
  rclone = import ./rclone.nix { inherit pkgs; };
  theme = import ./gtk_themes.nix { inherit pkgs; };
  fonts = import ./fonts.nix { inherit pkgs; };
in
{

  home.stateVersion = "23.05";
  home.packages = [ pkgs.atool pkgs.httpie pkgs.oh-my-zsh ];
  

  home.file.".zshrc".text = '' 
    export ZSH=${pkgs.oh-my-zsh}/share/oh-my-zsh/
    
    ZSH_THEME="robbyrussell"
    plugins=(git cargo ansible colored-man-pages pip rust rustup sudo)
   
    source $ZSH/oh-my-zsh.sh
    
    alias cat="bat"
    alias ls="exa"

  '';

  imports = [ alacritty btop rclone theme fonts];
}
