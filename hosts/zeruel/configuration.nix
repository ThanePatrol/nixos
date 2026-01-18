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
  rcloneConfPath = "/home/hugh/.config/rclone/rclone.conf";
  homeDirectory = "/home/hugh";
  ssdFolder = "/home/hugh/SSDs";
  hddBackupFolder = "/home/hugh/Backups";
  ssdBackupSystemdServiceName = "backup-local";

  tenGbEthernetPort1 = "enp36s0f0"; # physically the bottom port
  tenGbEthernetPort2 = "enp36s0f1";
  _onboardGigabitEthernetPort1 = "enp38s0";
  onboardGigabitEthernetPort2 = "enp39s0"; # physically the bottom port
  _managementPort = "enp42s0f3u5u3c2";

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

  syspackages = import ../../system/linux/packages/packages.nix { inherit pkgs; };
in
{
  imports = [
    ./hardware-configuration.nix
  ];
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Bootloader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    supportedFilesystems = [ "btrfs" ];

    kernelPackages = pkgs.linuxPackages_latest;

    kernelParams = [
      "transparent_hugepage=madvise"
    ];
  };

  fileSystems."${ssdFolder}" = {
    device = "/dev/disk/by-uuid/e9d7c34a-bf3c-45d0-bb00-5aeb26d998e0";
    fsType = "btrfs";
    options = [
      "noatime"
      "nodev"
      "nosuid"
    ];
  };

  systemd.services."${ssdBackupSystemdServiceName}" = {
    description = "Mount HDD and backup files";
    script = ''
      if [ ! -d ${hddBackupFolder} ]; then
        ${pkgs.coreutils}/bin/mkdir ${hddBackupFolder}
      fi

      if ${pkgs.coreutils}/bin/grep -qs " ${hddBackupFolder} " /proc/mounts; then
        echo "file system already mounted"
      else
        ${pkgs.util-linux}/bin/mount -o noatime,nodev,nosuid,noexec -t btrfs /dev/disk/by-uuid/0bea86cf-242e-4ec8-9365-7c4b375df50e ${hddBackupFolder}
        ${pkgs.coreutils}/bin/chown -R ${username} ${hddBackupFolder}
        echo "mounted hdds"
      fi

      new_folder_name=${hddBackupFolder}/"backup-$(${pkgs.coreutils}/bin/date -u +%Y-%m-%d_%H.%M.%S%Z)"
      ${pkgs.coreutils}/bin/mkdir "$new_folder_name"
      # remove all but the latest 3 dirs, if less than 3 do nothing - assume no other files in here!
      ${pkgs.coreutils}/bin/ls ${hddBackupFolder} | ${pkgs.coreutils}/bin/sort | ${pkgs.coreutils}/bin/head -n -3 | ${pkgs.findutils}/bin/xargs -I {} ${pkgs.coreutils}/bin/rm -r ${hddBackupFolder}/{} || true
      ${pkgs.coreutils}/bin/echo "Removed old backups"

      # prevent shutdown until backup finishes
      ${pkgs.systemd}/bin/systemd-inhibit --why="backing up ssds! 😋" ${pkgs.rclone}/bin/rclone --config=${rcloneConfPath} sync ${ssdFolder} "$new_folder_name"

      ${pkgs.util-linux}/bin/umount ${hddBackupFolder}
    '';
  };

  systemd.timers.init-backup = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "10m";
      Unit = "${ssdBackupSystemdServiceName}.service";
    };
  };

  systemd.services.run-monthly-rent-payments = {
    script = ''
      	${pkgs.curl}/bin/curl -d "/home/hugh/dev/rent/thanhtra2004@gmail.com.json" --request POST localhost:2999
      	'';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

  systemd.timers.run-monthly-rent-payments = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-25 00:00:00";
      Unit = "run-monthly-rent-payments.service";
    };
  };

  systemd.services.run-imad-rent-payments = {
    script = ''
        ${pkgs.curl}/bin/curl -d "/home/hugh/dev/rent/kazmiimad@gmail.com.json" --request POST localhost:2999
      	'';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

  systemd.timers.run-imad-rent-payments = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Unit = "run-imad-rent-payments.service";
    };
  };

  systemd.services.run-xml-scrape = {
    script = ''
      /home/hugh/dev/trader/target/release/rss
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

  systemd.timers.run-xml-scrape = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "1h";
      Unit = "run-xml-scrape.service";
      RandomizedDelaySec = "10m"; # Don't scrape at the same time
    };
  };

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    cpu.amd = {
      updateMicrocode = true;
    };
    keyboard = {
      qmk.enable = true;
    };
    graphics = {
      enable32Bit = true;
    };
  };

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  networking = {
    networkmanager.enable = false;
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
    hostName = "zeruel";
  };

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    age.keyFile = "/home/${username}/.config/sops/age/keys.txt";
    age.generateKey = false;
    secrets = {
      # This is the actual specification of the secrets.
      wifi_password = { };
    };
  };

  programs = {
    hyprland.enable = true;
    zsh.enable = true;
    steam.enable = true;

    # to get virt-manager working: https://github.com/NixOS/nixpkgs/issues/42433
    dconf.enable = true;
    virt-manager.enable = true;
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
    };
  };

  services.nfs.server = {
    enable = true;
    exports = ''
      	/home/hugh/SSDs    10.0.0.118/24(insecure,rw,sync,no_subtree_check)
      	'';
    # fixed rpc.statd port; for firewall
    lockdPort = 4001;
    mountdPort = 4002;
    statdPort = 4000;
  };
  networking.firewall = {
    enable = true;
    # for NFSv3; view with `rpcinfo -p`
    allowedTCPPorts = [
      111
      2049
      2283 # immich
      3000 # general dev
      4000
      4001
      4002
      5055 # Jellyseer
      20048
      25565 # MC
    ];
    allowedUDPPorts = [
      111
      2049
      4000
      4001
      4002
      5055 # Jellyseer
      20048
      25565 # MC
    ];
  };

  services = {
    # Enable clipboard sharing to VM
    spice-vdagentd.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      audio.enable = true; # set as default sound server
      pulse.enable = true;
      wireplumber.enable = true;
    };
  };

  # to allow swaylock to accept a password
  security.pam.services.swaylock = { };

  security.rtkit.enable = true;

  # Enable sound with pipewire.

  home-manager.useGlobalPkgs = true;
  home-manager.users.${username} = homeConfig;

  users.users.${username} = {
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
    ];
    shell = pkgs.zsh;
  };

  environment.systemPackages = syspackages.environment.systemPackages;

  environment.pathsToLink = [
    "/share/zsh"
    "/share/icons" # For Xournalpp not finding icons
    "/share/mime" # https://github.com/NixOS/nixpkgs/issues/163107
  ];

  virtualisation = {

    docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };

    libvirtd = {
      enable = true;
      qemu.package = pkgs.qemu;
    };
  };

  # services.paperless = {
  #   enable = true;
  # };

  services.immich = {
    enable = true;
    port = 2283;
    host = "0.0.0.0";
    #mediaLocation = "${ssdFolder}/immich";
  };

  systemd.services = {
    docker.wantedBy = [ "multi-user.target" ];
    libvirtd.enable = true;
    virtlogd.enable = true;
  };

  services.passSecretService.enable = true;

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
  system.stateVersion = "24.11"; # Did you read the comment?

}
