{ nixpkgs, lib, config, pkgs, customArgs, ... }:

let


in {
  # TODO - font + terminal theme setup
  environment.packages = with pkgs; [
    gnumake
    gawk
    gnused
    gnugrep
    rustc
    cargo
    rustup
    cargo-watch
    python3
  ];

  user.shell = "${pkgs.zsh}/bin/zsh";

  terminal = {
    font = "${pkgs.nerdfonts}/share/fonts/truetype/JetBrainsMonoNerdFont-Regular.ttf";
  };

  environment.etcBackupExtension = ".bak";

  system.stateVersion = "23.11";

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
}
