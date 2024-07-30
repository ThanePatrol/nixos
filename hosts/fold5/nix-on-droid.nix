{ nixpkgs, lib, config, pkgs, customArgs, ... }:

let

in {
  environment.packages = with pkgs; [
    gnumake
    gawk
    gnused
    gnugrep
    neofetch
    rustup
    cargo-watch
    python3
    direnv
    findutils
    ripgrep
  ];

  user.shell = "${pkgs.zsh}/bin/zsh";

  android-integration.termux-open.enable = true;

  terminal = {
    font =
      "${pkgs.nerdfonts}/share/fonts/truetype/JetBrainsMonoNerdFont-Regular.ttf";
    colors = {
      background = "#1E1E2E";
      foreground = "#CDD6F4";

      color0 = "#45475A";
      color8 = "#585B70";

      color1 = "#F38BA8";
      color9 = "#F38BA8";

      color2 = "#A6E3A1";
      color10 = "#A6E3A1";

      color3 = "#F9E2AF";
      color11 = "#F9E2AF";

      color4 = "#89B4FA";
      color12 = "#89B4FA";

      color5 = "#F5C2E7";
      color13 = "#F5C2E7";

      color6 = "#94E2D5";
      color14 = "#94E2D5";

      color7 = "#BAC2DE";
      color15 = "#A6ADC8";
    };
  };

  environment.etcBackupExtension = ".bak";

  system.stateVersion = "23.11";

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
}
