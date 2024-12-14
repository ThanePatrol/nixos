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
  username = customArgs.username;
  email = customArgs.email;
  gitUserName = customArgs.gitUserName;
  ssdFolder = "/home/hugh/nas";
  hddBackupFolder = "/home/hugh/backups";
  ssdBackupSystemdServiceName = "backup-local";

  theme = "Catppuccin-mocha";

  homeConfig = import ../../home/home.nix {
    inherit
      email
      isWork
      isDarwin
      username
      gitUserName
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
    supportedFilesystems = [ "bcachefs" ];
    # use latest linux kernel
    kernelPackages = pkgs.linuxPackages_latest;

    # TODO add "video=DP-2:3840x2160" or similar for game streaming
    kernelParams = [
      "transparent_hugepage=madvise"
    ];
  };

  systemd.services.mount-nas = {
    description = "Mount NAS SSDs";
    # workaround for lack of systemd support for multidisk file systems  https://github.com/systemd/systemd/issues/8234
    # bcachefs creates a new disk with a uuid when you have a multi disk setup
    script = ''
      if [ ! -d ${ssdFolder} ]; then
        ${pkgs.coreutils}/bin/mkdir ${ssdFolder}
        ${pkgs.coreutils}/bin/chown -R ${username} ${ssdFolder}
      fi
      if ${pkgs.util-linux}/bin/mountpoint -q ${ssdFolder}; then
          ${pkgs.util-linux}/bin/umount ${ssdFolder}
      fi
        ${pkgs.util-linux}/bin/mount -o noatime,nodev,nosuid -t bcachefs /dev/disk/by-uuid/bec8ac82-6ebb-4daa-9d7c-8f1289ddb78a ${ssdFolder}
        ${pkgs.coreutils}/bin/chown -R ${username} ${ssdFolder}
    '';
    wantedBy = [ "multi-user.target" ];
  };

  systemd.services."${ssdBackupSystemdServiceName}" = {
    description = "Mount HDD and backup files";
    script = ''
      if [ ! -d ${hddBackupFolder} ]; then
        ${pkgs.coreutils}/bin/mkdir ${hddBackupFolder}
      fi
      if [ ! ${pkgs.util-linux}/bin/mountpoint -q ]; then
        ${pkgs.util-linux}/bin/mount -o noatime,nodev,nosuid,noexec -t btrfs /dev/disk/by-uuid/0bea86cf-242e-4ec8-9365-7c4b375df50e ${hddBackupFolder}
      fi

      new_folder_name=${hddBackupFolder}/"backup-$(${pkgs.coreutils}/bin/date -u +%Y-%m-%d_%H.%M.%S%Z)"
      ${pkgs.coreutils}/bin/mkdir "$new_folder_name"
      # remove all but the latest 3 dirs, if less than 3 do nothing - assume no other files in here!
      ${pkgs.coreutils}/bin/ls ${hddBackupFolder} | ${pkgs.coreutils}/bin/sort | ${pkgs.coreutils}/bin/head -n -3 | ${pkgs.findutils}/bin/xargs -I {} ${pkgs.coreutils}/bin/rm {}

      # prevent shutdown until backup finishes
      ${pkgs.systemd}/bin/systemd-inhibit --why="backing up ssds! 😋" ${pkgs.rclone}/bin/rclone sync ${ssdFolder} "$new_folder_name"

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

  # fileSystems = {
  #   "/home/hugh/nas" = {
  #     device = "/dev/disk/by-uuid/28a15d8d-8c3f-4b4e-8c4b-799b7926068f:/dev/disk/by-uuid/ae07e42b-ae8b-4e38-9e16-aac8721b193f";
  #     fsType = "bcachefs";
  #   };
  # };

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

  networking = {
    networkmanager.enable = true;
    hostName = "zeruel"; # Define your hostname.
    firewall = {
      enable = false;
      allowedTCPPortRanges = [
        # minecraft
        {
          from = 25565;
          to = 25565;
        }
      ];
      allowedUDPPortRanges = [
        {
          from = 25565;
          to = 25565;
        }
      ];
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

  # FIXME - do we really want this on a server?
  services = {
    udev = {
      packages = with pkgs; [ via ];
      extraRules = ''
        KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"
        ACTION=="add", SUBSYSTEM=="block", SUBSYSTEMS=="usb", ENV{ID_FS_USAGE}=="filesystem", RUN+="${pkgs.systemd}/bin/systemd-mount --no-block --automount=yes --collect $devnode /home/hugh/removable"
      '';
    };
    # Enable clipboard sharing to VM
    spice-vdagentd.enable = true;
    openssh.enable = true;
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
