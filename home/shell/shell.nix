{ pkgs, lib, ... }:

{
   home.packages = [ pkgs.atool pkgs.httpie pkgs.oh-my-zsh pkgs.imhex ];
  

    home.sessionPath = [ 
      "${pkgs.tectonic}/bin"
    ];

    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        add_newline = true;
        
        character = {
          success_symbol = "[❯](maroon)";
          error_symbol = "[❯](red)";
          vimcmd_symbol = "[❮](green)";
        };
        format = lib.concatStrings[
          "$directory"
          "$line_break"
          "$character"
        ];

        git_branch = {
          format = "[$branch]($style) ";
          symbol = " ";
        };

        git_status = {
          format = "[[($conflicted$untracked$modified$staged$renamed$deleted)](218) ($ahead_behind$stashed)]($style)";
          conflicted = "";
          untracked = ""; 
          modified = "";
          staged = "";
          renamed = "";
          deleted = "";
          #stashed = "≡ ";
          ahead = "⇡ ";
        };

        docker_context = {
          symbol = "🐋";
        };
        c = {
          symbol = "🔧";
        };
        helm = {
          symbol = "⎈ ";
        };
        java = {
          symbol = "☕ ";
        };
        lua = {
          symbol = "🌙 ";
        };
        nix-shell = {
          symbol = "❄️ ";
        };
        nodejs = {
          symbol = "⬢ ";
        };
        python = {
          symbol = "🐍 ";
        };
        rust = {
          symbol = "🦀 ";
        };
        sudo = {
          symbol = "🧙 ";
        };
        terraform = {
          symbol = "💠 ";
        };
        right_format = "$all";
        palette = "catppuccin_mocha";
        palettes.catppuccin_mocha = {
          rosewater = "#f5e0dc";
          flamingo = "#f2cdcd";
          pink = "#f5c2e7"; # put semicolons on the end of each line
          mauve = "#cba6f7";
          red = "#f38ba8";
          maroon = "#eba0ac";
          peach = "#fab387";
          yellow = "#f9e2af";
          green = "#a6e3a1";
          teal = "#94e2d5";
          sky = "#89dceb";
          sapphire = "#74c7ec";
          blue = "#89b4fa";
          lavender = "#b4befe";
          text = "#cdd6f4";
          subtext1 = "#bac2de";
          subtext0 = "#a6adc8";
          overlay2 = "#9399b2";
          overlay1 = "#7f849c";
          overlay0 = "#6c7086";
          surface2 = "#585b70";
          surface1 = "#45475a";
          surface0 = "#313244";
          base = "#1e1e2e";
          mantle = "#181825";
          crust = "#11111b";
        };
     };
   };

  programs.zsh = {
     enable = true;
     enableCompletion = true;
     enableAutosuggestions = true;
     envExtra = ''

      export EDITOR="nvim"
      export STARSHP_CONFIG="$HOME/.config/starship.toml"

      export XDG_DATA_DIRS="/var/lib/flatpak/exports/share:/home/hugh/.local/share/flatpak/exports/share:$XDG_DATA_DIRS"
       
      export IMHEX=${pkgs.imhex}/bin
      export CHROME_BIN=${pkgs.google-chrome}/bin
      export CHROMEDRIVER=${pkgs.chromedriver}/bin
      '';
     
      shellAliases = {
        ".." = "cd ..";
        ll = "ls -l";
        open = "xdg-open";
        cat = "bat";
        update = "sudo nix-channel --update && sudo cp -r ~/nixos/* /etc/nixos && sudo nixos-rebuild switch && sudo nix-env --delete-generations 7d";
        clean = "nix-collect-garbage && nix-store --optimise";
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
     ];
     initExtra = ''
        eval "$(direnv hook zsh)"
        eval "$(starship init zsh)"
      
     '';
   };
   
  #home.file.".zshrc".text = ''
  #   eval "$(starship init zsh)"
  #   eval "$(direnv hook zsh)"
  # '';

} 
 
