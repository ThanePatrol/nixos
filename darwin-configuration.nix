{ config, pkgs, ... }:
let 
  user_name = "hugh";
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
      "docker-completion"
      "yabai"
      "skhd"
      "mas" # mac app store cli - needs xcode installed
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
    masApps = {
      Xcode = 497799835;
    };
  };

  system.defaults.NSGlobalDomain = {
    AppleInterfaceStyle = "Dark";
  };

  system.defaults.dock = {
    autohide = true;
    show-recents = false;
  };

  system.defaults.finder = {
    AppleShowAllExtensions = true;
    CreateDesktop = false;
    FXPreferredViewStyle = "clmv";
    ShowPathbar = true;
    QuitMenuItem = true;
    _FXShowPosixPathInTitle = true;

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
