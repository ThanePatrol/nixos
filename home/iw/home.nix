{ pkgs, ... }:

let
  packages = with pkgs; [
    zsh-powerlevel10k
    ripgrep
    fzf
    gzip
    zip
    unzip
    jq
    neovim
    tmux
    fzf
    jujutsu
  ];

in
{
  home.username = "iw";
  home.homeDirectory = "/home/iw";
  home.packages = packages;

  home.stateVersion = "23.05";
  news.display = "silent";

  programs.home-manager.enable = true;

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;

    # Source p10k.zsh for prompt and other zsh plugins
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
      # {
      #   name = "powerlevel10k-config";
      #   src = ./.;
      #   file = "p10k.zsh";
      # }
    ];

    # Adapted from imperative .zshrc
    initContent = ''
      setopt histignorealldups sharehistory inc_append_history interactive_comments

      bindkey '^F' history-incremental-search-forward

      # TODO Add as needed other zsh config and shell variables like SSH_AUTH_SOCK

      source "$HOME/dotfiles/shell/.p10k.zsh"
      source "$HOME/dotfiles/shell/.aliases"

      eval "$(${pkgs.fzf}/bin/fzf --zsh)"

      if ! tmux list-sessions >/dev/null 2>&1; then
        tmux new -s dev
      fi
    '';
  };
}
