{
  isWork,
  isDarwin,
  pkgs,
  ...
}:

let
  macExports = ''
    export NIX_PATH=darwin-config=$HOME/.nixpkgs/darwin-configuration.nix:$NIX_PATH
  '';

  macInit = ''
    export LIBRARY_PATH=$HOME/.nix-profile/lib:$LIBRARY_PATH
    export PATH=${pkgs.gnused}/bin:$PATH
  '';

  workExports = ''
    export PATH="$PATH:$HOME/.nix-profile/bin"
  '';

in
{

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    envExtra =
      ''
        export EDITOR="nvim"
      ''
      + (if isDarwin then macExports else "");

    shellAliases = {
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      ll = "ls -l";
      ls = "ls --color=auto";
      open = (if isDarwin then "open" else "xdg-open");
      cat = "bat";
      gsed = (if isDarwin then "${pkgs.gnused}/bin/sed" else "");
      nv = "nvim";
      gbn = "git branch --show-current";
      gc = "git commit -m";
      gp = "git push";
      ga = "git add .";
      gs = "git status -s";
      dc = "docker compose";
      # hack for resetting clipboard when it starts playing up on macos
      rclip = "sudo launchctl stop com.apple.pboard && sudo launchctl start com.apple.pboard && pbcopy < /dev/null";
      # TODO make portable for linux
      unix-to-date = ''date -u -d @"$(($(pbpaste) / 1000))" +%Y%m%d | tee >(pbcopy)'';
      genpw = "tr -dc A-Za-z0-9 </dev/urandom | head -c 30 | tee >(pbcopy)";
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
    initExtra =
      ''
        # Remove logging of direnv. Revisit when https://github.com/direnv/direnv/pull/1231 is approved
        export DIRENV_LOG_FORMAT=
        eval "$(direnv hook zsh)"

        source "${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

        eval "$(${pkgs.fzf}/bin/fzf --zsh)"

        export PATH=$PATH:$HOME/.local/bin

        bindkey "^[f" forward-word
        bindkey "^[b" backward-word

      ''
      + (if isDarwin then macInit else "")
      + (if isWork then workExports else "");
  };
}
