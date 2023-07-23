{ pkgs, ... }:

{
   home.packages = [ pkgs.atool pkgs.httpie pkgs.oh-my-zsh ];


   home.file.".zshrc".text = ''
     export ZSH=${pkgs.oh-my-zsh}/share/oh-my-zsh/

     ZSH_THEME="robbyrussell"
     plugins=(git cargo ansible colored-man-pages pip rust rustup sudo)

     source $ZSH/oh-my-zsh.sh

     alias open="xdg-open"
     alias cat="bat"
     alias ls="exa"

   '';

} 
 
