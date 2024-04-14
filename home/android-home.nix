{ email, isWork, isDarwin, username, gitUserName, theme, lib, pkgs, ... }:

let


in {

  home.username = "${username}";

  home.homeDirectory = "/data/data/com.termux.nix/files/home";
  home.stateVersion = "23.05";

  imports = [
    (import ./common/bat/bat.nix { inherit theme; })
    (import ./common/btop/btop.nix { inherit theme pkgs; })
    (import ./common/ssh.nix { inherit gitUserName; })
    (import ./common/shell/shell.nix {
      inherit isWork isDarwin theme pkgs lib;
    })
    (import ./common/git.nix { inherit email gitUserName theme; })
    (import ./common/nvim/nvim.nix { inherit pkgs lib theme; })
    (import ./common/tmux.nix { inherit isDarwin theme pkgs; })
  ];
}
