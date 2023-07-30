{ pkgs, ... }:

{
   home.packages = [ pkgs.atool pkgs.httpie pkgs.oh-my-zsh pkgs.imhex ];


   home.file.".zshrc".text = ''
     export ZSH=${pkgs.oh-my-zsh}/share/oh-my-zsh/

     export XDG_DATA_DIRS="/var/lib/flatpak/exports/share:/home/hugh/.local/share/flatpak/exports/share:$XDG_DATA_DIRS"
     
     export IMHEX=${pkgs.imhex}/bin
     
     ZSH_THEME="agnoster"
     plugins=(git cargo ansible colored-man-pages pip rust rustup sudo)

     source $ZSH/oh-my-zsh.sh

     alias open="xdg-open"
     alias cat="bat"
     alias ls="exa"
     alias update="sudo cp -r ~/nixos /etc/nixos && sudo nixos-rebuild switch"

   '';

} 
 
