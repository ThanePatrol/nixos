{ pkgs, ... }:

{
   home.packages = [ pkgs.atool pkgs.httpie pkgs.oh-my-zsh pkgs.imhex ];
  

   home.sessionPath = [ 
     "${pkgs.tectonic}/bin"
   ];
  
  programs.zsh.oh-my-zsh = {
    enable = true;
    plugins = [
      "git"
      "cargo"
      "colored-man-pages"
      "pip"
      "rust"
      "rustup"
      "sudo"
    ];

  };
  

   home.file.".zshrc".text = ''
     export ZSH=${pkgs.oh-my-zsh}/share/oh-my-zsh/

     export XDG_DATA_DIRS="/var/lib/flatpak/exports/share:/home/hugh/.local/share/flatpak/exports/share:$XDG_DATA_DIRS"
     
     export IMHEX=${pkgs.imhex}/bin
     export CHROME_BIN=${pkgs.google-chrome}/bin
     export CHROMEDRIVER=${pkgs.chromedriver}/bin

     ZSH_THEME="refined" #could not be defined by home-manager

     source $ZSH/oh-my-zsh.sh

     eval "$(direnv hook zsh)"

     alias open="xdg-open"
     alias cat="bat"
     alias ls="eza"
     alias update="sudo nix-channel --update && sudo cp -r ~/nixos/* /etc/nixos && sudo nixos-rebuild switch && sudo nix-env --delete-generations 7d"
     alias clean="nix-collect-garbage && nix-store --optimise"
     alias nv="nvim"
     alias vim="nvim"
   '';

} 
 
