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
    # use latest linux kernel
    kernelPackages = pkgs.linuxPackages_latest;

    # TODO add "video=DP-2:3840x2160" or similar for game streaming
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

  # Pay every second monday if week is even because cron can't hack it 😭
  #''0 0 * * MON hugh case $(($(date +\%s) / (60*60*24*7))) in *[02468]) curl -d "/home/hugh/dev/rent/jericocherreguine@gmail.com" --request POST localhost:2999;; esac ''
  # Notify monthly paying renters
  systemd.services.run-fortnight-rent-payments = {
    script = ''
      echo "running jerico"
      case $(($(date +\%s) / (60*60*24*7))) in *[02468]) ${pkgs.curl}/bin/curl -d "/home/hugh/dev/rent/jericocherreguine@gmail.com.json" --request POST localhost:2999;; esac
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

  systemd.timers.run-fortnight-rent-payments = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Unit = "run-fortnight-rent-payments.service";
    };
  };

  systemd.services.run-monthly-rent-payments = {
    script = ''
      	${pkgs.curl}/bin/curl -d "/home/hugh/dev/rent/thanhtra2004@gmail.com.json" --request POST localhost:2999
        ${pkgs.curl}/bin/curl -d "/home/hugh/dev/rent/kazmiimad@gmail.com.json" --request POST localhost:2999
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

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv6.conf.all.forwarding" = true;
    "net.ipv4.conf.br-lan.rp_filter" = 1;
    "net.ipv4.conf.${onboardGigabitEthernetPort2}.rp_filter" = 1;
  };

  systemd.network = {
    wait-online.anyInterface = true;

    netdevs = {
      # Create the bridge interface
      "20-br-lan" = {
        netdevConfig = {
          Kind = "bridge";
          Name = "br-lan";
        };
      };
    };
    networks = {
      "30-lan0" = {
        matchConfig.Name = tenGbEthernetPort1;
        linkConfig.RequiredForOnline = "enslaved";
        networkConfig = {
          Bridge = "br-lan";
          ConfigureWithoutCarrier = true;
        };
      };
      "30-lan1" = {
        matchConfig.Name = tenGbEthernetPort2;
        linkConfig.RequiredForOnline = "enslaved";
        networkConfig = {
          Bridge = "br-lan";
          ConfigureWithoutCarrier = true;
        };
      };
      # Configure bridge
      "40-br-lan" = {
        matchConfig.Name = "br-lan";
        bridgeConfig = { };
        address = [
          "10.0.1.1/24"
        ];
        networkConfig = {
          ConfigureWithoutCarrier = true;
        };
        linkConfig.RequiredForOnline = "no";
      };
      "10-wan" = {
        matchConfig.Name = onboardGigabitEthernetPort2;
        networkConfig = {
          # start a DHCP Client for IPv4 Addressing/Routing
          DHCP = "ipv4";
          IPv6AcceptRA = true;
          DNSOverTLS = true;
          DNSSEC = true;
          IPv6PrivacyExtensions = true;
          IPv4Forwarding = true;
          IPv6Forwarding = true;
        };
        # make routing on this interface a dependency for network-online.target
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };
  services.resolved.enable = false;

  networking = {
    networkmanager.enable = true;
    hostName = "zeruel";
    useNetworkd = true;
    interfaces.${onboardGigabitEthernetPort2}.useDHCP = false;

    nat.enable = false;
    firewall.enable = false;

    nftables = {
      enable = true;
      checkRuleset = true;
      ruleset = ''
        table inet filter {

          chain input {
            type filter hook input priority 0; policy drop;

            iifname { "br-lan" } accept comment "Allow local network to access the router"
            iifname "${onboardGigabitEthernetPort2}" ct state { established, related } accept comment "Allow established traffic"
            iifname "${onboardGigabitEthernetPort2}" icmp type { echo-request, destination-unreachable, time-exceeded } counter accept comment "Allow select ICMP"
            iifname "${onboardGigabitEthernetPort2}" counter drop comment "Drop all other unsolicited traffic from wan"
            iifname "lo" accept comment "Accept everything from loopback interface"
          }
          chain forward {
            type filter hook forward priority filter; policy drop;

            iifname { "br-lan" } oifname { "${onboardGigabitEthernetPort2}" } accept comment "Allow trusted LAN to WAN"
            iifname { "${onboardGigabitEthernetPort2}" } oifname { "br-lan" } ct state { established, related } accept comment "Allow established back to LANs"
          }
        }

        table ip nat {
          chain postrouting {
            type nat hook postrouting priority 100; policy accept;
            oifname "${onboardGigabitEthernetPort2}" masquerade
          }
        }
      '';
    };
  };

  services.dnsmasq = {
    enable = true;
    settings = {
      server = [
        "9.9.9.9"
        "8.8.8.8"
        "1.1.1.1"
      ];
      # sensible behaviours
      domain-needed = true;
      bogus-priv = true;
      no-resolv = true;

      # Cache dns queries.
      cache-size = 1000;

      dhcp-range = [ "br-lan,10.0.1.50,10.0.1.254,24h" ];
      interface = "br-lan";
      dhcp-host = "10.0.1.1";

      # local domains
      local = "/lan/";
      domain = "lan";
      expand-hosts = true;

      # don't use /etc/hosts as this would advertise as localhost
      no-hosts = true;
      address = [
        "/zeruel.lan/10.0.1.1"
      ];
    };
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
  #   mediaDir = "${ssdFolder}/paperless/media";
  #   dataDir = "${ssdFolder}/paperless/data";
  #   port = 28981;
  # };

  # services.immich = {
  #   enable = true;
  #   port = 2283;
  #   mediaLocation = "${ssdFolder}/immich";
  # };

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
