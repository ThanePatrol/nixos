{ nixpkgs, config, pkgs, lib, customArgs, ... }:

let
  isWork = customArgs.isWork;
  username = customArgs.username;
  email = customArgs.email;
  gitUserName = customArgs.gitUserName;
  isDarwin = true;
  theme = if builtins.getEnv ("THEME") == "" then
    "Catppuccin-mocha"
  else
    builtins.getEnv ("THEME");
  homeConfig = import ../../home/home.nix {
    inherit email isWork isDarwin gitUserName username theme nixpkgs pkgs config
      lib;
  };
in {
  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
  };

  home-manager.users.${username} = homeConfig;
  home-manager.useGlobalPkgs = true;

  environment.systemPackages = [ ];

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
      "calibre"
      "docker"
      "firefox"
      "signal"
      "spotify"
      "vlc"
      "zotero"
      "anki"
      "qbittorrent"
    ];
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

  networking.wg-quick.interfaces = {
    "eno" = {
      # Don't actually care about privateKeyFile
      # resolves some nix error
      privateKeyFile = "";
      # only mount nfs drive if connected to home router
      postUp = ''
        home_mac_addr="34:e8:94:3e:f0:e1"
        function get_ip() {
          ping -c 4 10.0.0.1
          # Extract the mac address of arp
          echo $(arp -a | head -n 1 | grep -io '[a-f0-9:]\{17\}')
        }  
        if [[ "$(get_ip)" == "$home_mac_addr" ]]; then
        sudo mount_nfs -o rw,resvport,auto,noatime,nolock,intr,tcp,actimeo=1800 -v 10.0.0.15:/mnt/samsung4tb/nas /Users/hugh/nfs/
        fi
      '';
      postDown = ''
        sudo umount /Users/hugh/nfs 
      '';
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
      DSDontWriteNetworkStores = true;
      DSDontWriteUSBStores = true;
    };
    "com.apple.ImageCapture".disableHotPlug = true;
    "com.apple.commerce".AutoUpdate = true;
  };

  services.nix-daemon.enable = true;
  nix.gc.automatic = true;

  programs.zsh.enable = true; # default shell on catalina

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
