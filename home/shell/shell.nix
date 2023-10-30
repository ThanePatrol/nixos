{ pkgs, lib, ... }:
let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  linuxUpdate =
    "sudo nix-channel --update && sudo cp -r ~/nixos/* /etc/nixos && sudo nixos-rebuild switch && sudo nix-env --delete-generations 7d";
  macUpdate =
    "cp -r ~/nixos/home/* ~/.config/home-manager && home-manager switch && yabai --stop-service && yabai --start-service && skhd -reload";
  linuxClean =
    "nix-collect-garbage && nix-store --optimise && sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than 7d";
  macClean = "nix-collect-garbage && nix-collect-garbage --delete-old && nix-store --optimise" ;
in {
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
      format = lib.concatStrings [ "$directory" "$line_break" "$character" ];

      git_branch = {
        format = "[$branch]($style) ";
        symbol = " ";
      };

      git_status = {
        format =
          "[[($conflicted$untracked$modified$staged$renamed$deleted)](218) ($ahead_behind$stashed)]($style)";
        conflicted = "≠";
        untracked = "";
        modified = "*";
        staged = "";
        renamed = "";
        deleted = "";

        #stashed = "≡ ";
        ahead = "⇡ ";
      };

      docker_context = { symbol = "🐋"; };
      c = { symbol = "🔧"; };
      helm = { symbol = "⎈ "; };
      java = { symbol = "☕ "; };
      lua = { symbol = "🌙 "; };
      nix_shell = { symbol = "❄️ "; };
      nodejs = { symbol = "⬢ "; };
      python = { symbol = "🐍 "; };
      rust = { symbol = "🦀 "; };
      sudo = { symbol = "🧙 "; };
      terraform = { symbol = "💠 "; };
      right_format = " $all";
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
    '';

    shellAliases = {
      ".." = "cd ..";
      "..." = "cd ...";
      ll = "ls -l";
      open = (if isDarwin then "open" else "xdg-open");
      cat = "bat";
      du = "dust";
      update = (if isDarwin then macUpdate else linuxUpdate);
      clean = (if isDarwin then macClean else linuxClean);
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
}

