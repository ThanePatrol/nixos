{ nixpkgs, config, pkgs, lib, isWork, username, ... }:

let 
  isDarwin = true;
  theme = if builtins.getEnv("THEME") == "" then
    "Catppuccin-mocha" # fallback to my fav theme if not set. Theme should always be in the Name-derv format
  else 
    builtins.getEnv("THEME");
  homeConfig = import ./home/home.nix {inherit isWork isDarwin username theme nixpkgs pkgs config lib; };
in {

  imports = [ <home-manager/nix-darwin> ];

  users.users.${username} = { 
    name = username;
    home = "/Users/${username}"; 
  };

  home-manager.users.${username} = homeConfig;
  home-manager.useGlobalPkgs = true;

  environment.systemPackages = [ ];


  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "terraform"
  ];

  homebrew = {
    enable = true;
    onActivation = {
      upgrade = true;
      autoUpdate = true;
    };

    # mainly used for cmd line tools not packaged by nix
    brews = [
      "nvm"
      "mas" # mac app store cli
    ];
    # mainly used for gui things
    casks = [
      "docker"
      "firefox"
      "signal"
      "eclipse-java"
      "spotify"
      "vlc"
      "zotero"
    ];
    # mac store apps when there is no cask, requires apple id login
    masApps = { Xcode = 497799835; };
  };

  # tiling window manager
  # enable service here, configure with home-manager
  services.yabai.enable = true;
  services.skhd.enable = true;

  # customer launcher at login
  launchd.user.agents = {
    "docker-desktop" = {
      script = "open -a Docker";
      serviceConfig = {
        Label = "com.docker.desktop.launch";
        RunAtLoad = true;
        StandardErrorPath = "/tmp/docker.err";
        StandardOutPath = "/tmp/docker.out";
      };
    };
  };

  system.defaults.NSGlobalDomain = {
    AppleInterfaceStyle = "Dark";
    "com.apple.swipescrolldirection" = false;
  };

  system.defaults.dock = {
    autohide = true;
    autohide-delay = 0.0;
    launchanim = false;

    show-recents = false;
  };

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
    #"AppleKeyboardUIMode" = 3;
    #"ApplePressAndHoldEnabled" = false;
  };

  system.defaults.finder = {
    AppleShowAllExtensions = true;
    CreateDesktop = false;
    FXPreferredViewStyle = "clmv";
    ShowPathbar = true;
    QuitMenuItem = true;
    _FXShowPosixPathInTitle = true;
  };

  system.activationScripts.postUserActivation.text = ''
    # Following line should allow us to avoid a logout/login cycle when changing settings
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';

  system.defaults.CustomUserPreferences = {
    "com.apple.desktopservices" = {
      # Avoid creating .DS_Store files on network or USB volumes
      # bane of my existence
      DSDontWriteNetworkStores = true;
      DSDontWriteUSBStores = true;
    };
    "com.apple.ImageCapture".disableHotPlug = true;
    "com.apple.commerce".AutoUpdate = true;

  # TODO when this is fixed, enable it
   # can't configure shortcuts yet
   # waiting on https://github.com/LnL7/nix-darwin/issues/185
   # "com.apple.symbolichotkeys".AppleSymbolicHotKeys = {
   #   "118" = {
   #     enabled = true;
   #       value = {
   #         parameters = [ 49 18 524288 ];
   #         type = "standard";
   #     };
   #   };
   # };
  };

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;
  nix.gc.automatic = true;

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true; # default shell on catalina

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
