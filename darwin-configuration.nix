{ config, pkgs, lib, ... }:
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

      "com.apple.symbolichotkeys" = {
        AppleSymbolicHotKeys = {
          "118" = {
            enabled = 1;
            value = {
              parameters = [49 18 524288];
              type = "standard";
            };
          };
          "119" = {
            enabled = 1;
            value = {
              parameters = [50 19 524288];
              type = "standard";
            };
          };
            "120" =             {
                enabled = 1;
                value = {
                    parameters = [
                        51
                        20
                        524288
                      ];
                    type = "standard";
                };
            };
            "121" =             {
                enabled = 1;
                value =                 {
                    parameters =                     [
                        52
                        21
                        524288
                      ];
                    type = "standard";
                };
            };
            122 =             {
                enabled = 1;
                value =                 {
                    parameters =                     (
                        53,
                        23,
                        524288
                    );
                    type = standard;
                };
            };
            123 =             {
                enabled = 1;
                value =                 {
                    parameters =                     (
                        54,
                        22,
                        524288
                    );
                    type = standard;
                };
            };
            124 =             {
                enabled = 1;
                value =                 {
                    parameters =                     (
                        55,
                        26,
                        524288
                    );
                    type = standard;
                };
            };
            125 =             {
                enabled = 1;
                value =                 {
                    parameters =                     (
                        56,
                        28,
                        524288
                    );
                    type = standard;
                };
            };
            126 =             {
                enabled = 1;
                value =                 {
                    parameters =                     (
                        57,
                        25,
                        524288
                    );
                    type = standard;
                };
            };
    };

    # https://github.com/LnL7/nix-darwin/issues/214
    # hack for getting nix apps to launch with spotlight
  system.activationScripts.applications.text = lib.mkForce ''
    echo "setting up ~/Applications..." >&2
    applications="$HOME/Applications"
    nix_apps="$applications/Nix Apps"

    # Needs to be writable by the user so that home-manager can symlink into it
    if ! test -d "$applications"; then
        mkdir -p "$applications"
        chown ${user_name}: "$applications"
        chmod u+w "$applications"
    fi

    # Delete the directory to remove old links
    rm -rf "$nix_apps"
    mkdir -p "$nix_apps"
    find ${config.system.build.applications}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
        while read src; do
            # Spotlight does not recognize symlinks, it will ignore directory we link to the applications folder.
            # It does understand MacOS aliases though, a unique filesystem feature. Sadly they cannot be created
            # from bash (as far as I know), so we use the oh-so-great Apple Script instead.
            /usr/bin/osascript -e "
                set fileToAlias to POSIX file \"$src\" 
                set applicationsFolder to POSIX file \"$nix_apps\"
                tell application \"Finder\"
                    make alias file to fileToAlias at applicationsFolder
                    # This renames the alias; 'mpv.app alias' -> 'mpv.app'
                    set name of result to \"$(rev <<< "$src" | cut -d'/' -f1 | rev)\"
                end tell
            " 1>/dev/null
        done
  '';


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
