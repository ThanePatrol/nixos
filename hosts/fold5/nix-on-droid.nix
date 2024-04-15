{ nixpkgs, lib, config, pkgs, customArgs, ... }:

let

in {
  # TODO - font + terminal theme setup
  environment.packages = with pkgs; [
    gnumake
    gawk
    gsed
    gnugrep
  ];

  environment.etcBackupExtension = ".bak";

  system.stateVersion = "23.11";

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
}
