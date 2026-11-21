{
  nixpkgs,
  lib,
  config,
  pkgs,
  customArgs,
  ...
}:

let
  isDarwin = false;
  isWork = customArgs.isWork;
  minimal = false;
  username = customArgs.username;
  email = customArgs.email;
  inputs = customArgs.inputs;
  gitUserName = customArgs.gitUserName;
  homeDirectory = customArgs.homeDirectory;
  theme = "Catppuccin-mocha";

  homeConfig = import ../../home/home.nix {
    inherit
      inputs
      email
      isWork
      isDarwin
      username
      gitUserName
      homeDirectory
      minimal
      nixpkgs
      pkgs
      config
      lib
      theme
      ;
  };

  syspackages = import ../../system/linux/packages/packages.nix { inherit pkgs isWork; };
in
{
  imports = [
    ./hardware-configuration.nix
    ./kernel.nix
  ];
  hardware.asahi = {
    enable = true;
    # Read from boot instead of aiming for absolute purity.
    # I don't really want binary blobs in the repo.
    peripheralFirmwareDirectory = null;
  };
  hardware.apple.touchBar = {
    enable = true;
    settings = {
      EnablePixelShift = true;
      AdaptiveBrightness = false;
    };
  };

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    age.keyFile = "/home/${username}/.config/sops/age/keys.txt";
    age.generateKey = false;
    secrets = {

      backblaze_key_id = {
        owner = "${username}";
      };
      backblaze_application_key = {
        owner = "${username}";
      };
    };
  };

  services.dbus.enable = true;
  security.polkit.enable = true;

  # Use instead of gnome keyring for secrets.
  services.oo7.enable = true;
  security.pam.services.login.oo7.enable = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.trusted-users = [
    "root"
    "hugh"
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      # Needs to be false for asahi.
      efi.canTouchEfiVariables = false;
    };
    tmp.useTmpfs = true;
    zswap.enable = true;
    supportedFilesystems = [ "ext4" ];
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024; # 16GiB
    }

  ];

  networking = {
    # Quad9
    nameservers = [
      "9.9.9.9"
      "149.112.112.112"
    ];
    hostName = "israfel";
    wireless.iwd = {
      enable = true;
      settings.General.EnableNetworkConfiguration = true;
    };
  };

  programs = {
    zsh.enable = true;
    dconf.enable = true;
    sway = {
      enable = true;
      # Do this to prevent foot being pulled in...
      extraPackages = with pkgs; [
        brightnessctl
        grim
        pulseaudio
        swayidle
        swaylock
        wmenu
      ];
    };
  };

  security.rtkit.enable = true;
  services = {
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = false;
      audio.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
  };

  home-manager.useGlobalPkgs = true;
  home-manager.users = {
    ${username} = homeConfig;
  };

  users.users = {
    ${username} = {
      isNormalUser = true;
      description = username;
      extraGroups = [
        "docker"
        "networkmanager"
        "wheel"
        "plugdev"
        "libvirtd"
        "audio"
        "input"
        "lp" # for bluetooth
        "bluetooth"
      ];
      shell = pkgs.zsh;
    };
  };

  environment.systemPackages = syspackages.environment.systemPackages;

  environment.pathsToLink = [
    "/share/zsh"
  ];

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu.package = pkgs.qemu;
    };
  };

  systemd.services = {
    docker.wantedBy = [ "multi-user.target" ];
    libvirtd.enable = true;
    virtlogd.enable = true;
  };

  # Set your time zone.
  time.timeZone = "Australia/Sydney";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_AU.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.11"; # Did you read the comment?
}
