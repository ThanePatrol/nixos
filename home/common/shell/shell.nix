{ isWork, isDarwin, theme, pkgs, lib, ... }:
let
  linuxClean =
    "nix-collect-garbage && nix-store --optimise && sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than 7d";
  macClean =
    "nix-collect-garbage && nix-collect-garbage --delete-old && nix-store --optimise && nix-store gc";

  macExports = ''
    export NIX_PATH=darwin-config=$HOME/.nixpkgs/darwin-configuration.nix:$NIX_PATH
  '';

  macInit = ''
    export NVM_DIR=~/.nvm
    source $(brew --prefix nvm)/nvm.sh
    export LIBRARY_PATH=$HOME/.nix-profile/lib:$LIBRARY_PATH
  '';

  workExports = "export PATH=$PATH:/opt/atlassian/bin";

in {

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    envExtra = ''
      export EDITOR="nvim"
    '' + (if isDarwin then macExports else "");

    shellAliases = {
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      ll = "ls -l";
      ls = "ls --color=auto";
      open = (if isDarwin then "open" else "xdg-open");
      cat = "bat";
      du = "dust";
      clean = (if isDarwin then macClean else linuxClean);
      gsed = (if isDarwin then "${pkgs.gnused}/bin/sed" else "");
      nv = "nvim";
    };
    plugins = [
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.zsh-syntax-highlighting;
      }
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "powerlevel10k-config";
        src = ./p10k-config;
        file = "p10k.zsh";
      }
    ];
    initExtra = ''
      eval "$(direnv hook zsh)"
    '' + (if isDarwin then macInit else "")
      + (if isWork then workExports else "");

  };
}

