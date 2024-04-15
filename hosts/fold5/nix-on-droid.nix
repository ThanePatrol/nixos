{ nixpkgs, lib, config, pkgs, customArgs, ... }:

let

#  homeConfig = import ../../home/android-home.nix {
#    inherit email isWork isDarwin username gitUserName nixpkgs pkgs config lib
#      theme;
#    };

in {
  # TODO - font + terminal theme setup
  environment.packages = with pkgs; [
    gnumake
    gawk
    gsed
    gnugrep
  ];

  #home-manager.config = homeConfig;

  environment.etcBackupExtension = ".bak";

  system.stateVersion = "23.11";

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
}
