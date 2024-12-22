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
  ssdFolder = "/home/hugh/SSDs";
  hddBackupFolder = "/home/hugh/Backups";
  rcloneConfPath = "/home/hugh/.config/rclone/rclone.conf";
  ssdBackupSystemdServiceName = "backup-local";
  tenGbEthernetPort1 = "enp36s0f0";
  tenGbEthernetPort2 = "enp36s0f1"; # TODO - identify physical location
  onboardGigabitEthernetPort1 = "enp38s0";
  onboardGigabitEthernetPort2 = "enp39s0"; # physically the bottom port
  managementPort = "enp42s0f3u5u3c2";
  wanID = 10;
  lanID = 20;

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
    #../../system/linux/modules/udev-rules.nix
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

    # allow forwarding of packets
    kernel.sysctl = {
      "net.ipv4.conf.all.forwarding" = true;
      "net.ipv6.conf.all.forwarding" = true;

      # do not configure ipv6 addresses by default
      "net.ipv6.conf.all.accept_ra" = 0;
      "net.ipv6.conf.all.autoconf" = 0;
      "net.ipv6.conf.all.use_tempaddr" = 0;
    };
  };

  # router config
  networking = {
    useDHCP = false;
    hostName = "zeruel";

    # use nftables instead of scripted routing
    nat.enable = false;
    firewall.enable = false;
    nftables = {
      enable = true;
      ruleset = ''
        table inet filter {
         # flowtable f {
         #   hook ingress priority 0;
         #   devices = { lan };
         # }
          # allow router to create output connections
          chain output {
            type filter hook output priority 100; policy accept;
          }
          # handle packets destined for the device itself
          chain input {
            type filter hook input priority filter; policy drop;

            # accept local inputs
            iifname {
              "lan",
            } counter accept

            # allow established connections from wan, drop everything else
            iifname "wan" ct state { established, related } counter accept
            iifname "wan" drop
          }
          # handle packets routed through but not destined for router
          chain forward {
            type filter hook forward priority filter; policy drop;

            # use flow table for more efficient processing
            # ip protocol { tcp, udp } flow offload @f

            iifname {
              "lan",
            } oifname {
              "wan",
            } counter accept comment "Allow LAN to WAN"

            iifname {
              "wan",
            } oifname {
              "lan",
            } ct state established,related counter accept comment "allow established connection back to lan"

          }
        }

        table ip nat {
          chain prerouting {
            type nat hook prerouting priority filter; policy accept;
          }

          # Setup NAT masquerading on the wan interface
          chain postrouting {
            type nat hook postrouting priority filter; policy accept;
            oifname "wan" masquerade
          }
        }
      '';
    };

    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
    vlans = {
      wan = {
        id = wanID;
        interface = onboardGigabitEthernetPort2;
      };
      lan = {
        id = lanID;
        interface = tenGbEthernetPort1;
      };
    };
    interfaces = {
      ${onboardGigabitEthernetPort1}.useDHCP = false;
      ${onboardGigabitEthernetPort2}.useDHCP = false;
      ${tenGbEthernetPort1}.useDHCP = false;
      ${tenGbEthernetPort2}.useDHCP = false;
      managementPort.useDHCP = true;

      wan.useDHCP = false;
      lan = {
        ipv4.addresses = [
          {
            address = "10.0.0.1";
            prefixLength = 24;
          }
        ];
      };
    };
  };

  # allow lan devices to get IPs!
  services.kea.dhcp4 = {
    enable = true;
    settings = {
      interfaces-config = {
        interfaces = [
          "lan"
        ];
      };
      rebind-timer = 2000;
      renew-timer = 1000;
      lease-database = {
        name = "/var/lib/kea/dhcp4.leases";
        persist = true;
        type = "memfile";
      };
      subnet4 = [
        {
          id = 1;
          pools = [
            {
              pool = "10.0.0.100 - 10.0.0.254";
            }
          ];
          subnet = "10.0.0.0/24";
        }
      ];
      valid-lifetime = 4000;
    };
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

      ${pkgs.util-linux}/bin/mount -o noatime,nodev,nosuid,noexec -t btrfs /dev/disk/by-uuid/0bea86cf-242e-4ec8-9365-7c4b375df50e ${hddBackupFolder}

      ${pkgs.coreutils}/bin/chown -R ${username} ${hddBackupFolder}

      new_folder_name=${hddBackupFolder}/"backup-$(${pkgs.coreutils}/bin/date -u +%Y-%m-%d_%H.%M.%S%Z)"
      ${pkgs.coreutils}/bin/mkdir "$new_folder_name"
      # remove all but the latest 3 dirs, if less than 3 do nothing - assume no other files in here!
      ${pkgs.coreutils}/bin/ls ${hddBackupFolder} | ${pkgs.coreutils}/bin/sort | ${pkgs.coreutils}/bin/head -n -3 | ${pkgs.findutils}/bin/xargs -I {} ${pkgs.coreutils}/bin/rm {}

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

  # networking = {
  #   networkmanager.enable = true;
  #   hostName = "zeruel"; # Define your hostname.
  #   firewall = {
  #     enable = false;
  #     allowedTCPPortRanges = [
  #       # minecraft
  #       {
  #         from = 25565;
  #         to = 25565;
  #       }
  #     ];
  #     allowedUDPPortRanges = [
  #       {
  #         from = 25565;
  #         to = 25565;
  #       }
  #     ];
  #   };
  # };

  programs = {
    hyprland.enable = true;
    zsh.enable = true;
    steam.enable = true;

    # to get virt-manager working: https://github.com/NixOS/nixpkgs/issues/42433
    dconf.enable = true;
    virt-manager.enable = true;
  };

  services = {
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
