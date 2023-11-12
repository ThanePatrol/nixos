{ config, pkgs, ... }:
let user_name = "hugh";
in {

  imports = [ <home-manager/nix-darwin> ];
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [ ];

  homebrew = {
    enable = true;
    onActivation = {
      upgrade = true;
      autoUpdate = true;
    };

    # mainly used for cmd line tools not packaged by nix
    brews = [
      "koekeishiya/formulae/yabai"
      "koekeishiya/formulae/skhd"
      "mas" # mac app store cli
    ];
    # mainly used for gui things
    casks = [
      "docker"
      "firefox"
      "signal"
      #      "bitwarden"
      "google-chrome"
      "intellij-idea"
      "spotify"
      "vlc"
      "zotero"
    ];
    # mac store apps when there is no cask
    masApps = { Xcode = 497799835; };
  };

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
    # Following line should allow us to avoid a logout/login cycle
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';

  system.defaults.CustomUserPreferences = {
    "com.apple.desktopservices" = {
              # Avoid creating .DS_Store files on network or USB volumes
              DSDontWriteNetworkStores = true;
              DSDontWriteUSBStores = true;
            };
      # Prevent Photos from opening automatically when devices are plugged in
      "com.apple.ImageCapture".disableHotPlug = true;
      # Turn on app auto-update
      "com.apple.commerce".AutoUpdate = true;
    };


  users.users.${user_name} = { home = "/Users/${user_name}"; };

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
