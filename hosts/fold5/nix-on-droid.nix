{ nixpkgs, lib, config, pkgs, customArgs, ... }:

let
  isDarwin = false;
  isWork = customArgs.isWork;
  username = customArgs.username;
  email = customArgs.email;
  gitUserName = customArgs.gitUserName;

  theme = if builtins.getEnv ("THEME") == "" then
    "Catppuccin-mocha" 
  else
    builtins.getEnv ("THEME");

  homeConfig = import ../../home/android-home.nix {
    inherit email isWork isDarwin username gitUserName nixpkgs pkgs config lib
      theme;
    };

in {
  environment.packages = with pkgs; [
  ];

  home-manager.config = homeConfig;

  environment.etcBackupExtenion = ".bak";

  system.stateVersion = "23.11";

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
}
