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
  immichBackupServiceName = "backup-immich";
  remoteBackupServiceName = "run-remote-backup";

  serviceNamesToMonitor = [
    ssdBackupSystemdServiceName
    immichBackupServiceName
    remoteBackupServiceName
    "get-connected-clients"
  ];

  _tenGbEthernetPort1 = "enp36s0f0"; # physically the bottom port
  _tenGbEthernetPort2 = "enp36s0f1";
  _onboardGigabitEthernetPort1 = "enp38s0";
  _onboardGigabitEthernetPort2 = "enp39s0"; # physically the bottom port
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

  # TODO: Use this once PR is merged: https://nixpk.gs/pr-tracker.html?pr=506919
  renamePrompt = ''
    llama-cli -hf unsloth/gemma-4-E4B-it-GGUF --prompt "
    You are a specialized media management assistant. Your task is to clean up movie and TV show filenames.

    Rules:

        TV Shows: Use the format Show_Name_S##_E##.ext. Replace spaces with underscores for TV shows. Remove all release tags, resolutions, and absolute episode numbers in brackets.

        Movies: Use the format Movie_Name_(Year).ext. Replace spaces with underscores for Movies. Ensure the year is in parentheses. Remove all codec, resolution, and group tags.

        Output: Provide ONLY the corrected filename. No explanations or conversational filler.
    Rename this according to the rules : 
  '';
  # TODO: Add this snippet
  # dir="/var/lib/qBittorrent/qBittorrent/downloads"; find "$dir" -path "$dir/temp" -prune -o -type f -printf '%p %Cs\n'
  # and check modification time to see if it should be fed to a llm to categorize and rename into shows/movies based upon the last time the script has run
  copyMoviesAndShows = pkgs.writeShellScriptBin "copy-movies-shows" ''
    while IFS= read -r -d "" file; do
      if ${pkgs.ripgrep}/bin/rg -q "(s|S)\d+.*(e|E)\d+" "$file"; then
        ${pkgs.rsync}/bin/rsync -azvP "$file" /var/lib/jellyfin/Shows &> /dev/null 
      else
        ${pkgs.rsync}/bin/rsync -azvP "$file" /var/lib/jellyfin/Movies &> /dev/null
      fi
    done < <(${pkgs.findutils}/bin/find /var/lib/qBittorrent/qBittorrent/downloads/ -type f -not -path "/var/lib/qBittorrent/qBittorrent/downloads/temp/*" \( -name "*.mp4" -o -name "*.mkv" \) -print0)

    ${pkgs.coreutils}/bin/chown -R jellyfin /var/lib/jellyfin
  '';

  syspackages = import ../../system/linux/packages/packages.nix { inherit pkgs; };
in
{
  imports = [
    ./hardware-configuration.nix
    ../../homelab/proxmox.nix
    ../../homelab/home-assistant.nix
    ../../homelab/monitoring.nix
    ../../homelab/remote.nix
  ];
  _module.args.toMonitor = serviceNamesToMonitor;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.trusted-users = [
    "root"
    "hugh"
  ];

  # Bootloader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    tmp.useTmpfs = true;
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

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          #ControllerMode = "bredr";
        };
      };
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

  services.qbittorrent = {
    enable = true;
    webuiPort = 8010;
    openFirewall = true;
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
        ${pkgs.util-linux}/bin/mount -o noatime,nodev,nosuid,noexec -t ext4 /dev/disk/by-uuid/70f28b15-ef28-40ba-be2d-3cccd40fd85c ${hddBackupFolder}
        ${pkgs.coreutils}/bin/chown -R ${username} ${hddBackupFolder}
        echo "mounted hdds"
      fi

      new_folder_name=${hddBackupFolder}/"backup-$(${pkgs.coreutils}/bin/date -u +%Y-%m-%d_%H.%M.%S%Z)"
      ${pkgs.coreutils}/bin/mkdir "$new_folder_name"
      # remove all but the latest dir, if less than 3 do nothing - assume no other files in here!
      # Relies upon sorting by date and head -n -3 not showing anything if less than 3.
      ${pkgs.coreutils}/bin/ls ${hddBackupFolder} | ${pkgs.coreutils}/bin/sort | ${pkgs.coreutils}/bin/head -n -3 | ${pkgs.findutils}/bin/xargs -I {} ${pkgs.coreutils}/bin/rm -r ${hddBackupFolder}/{} || true
      ${pkgs.coreutils}/bin/echo "Removed old backups"

      # prevent shutdown until backup finishes
      ${pkgs.systemd}/bin/systemd-inhibit --why="backing up ssds! 😋" ${pkgs.rclone}/bin/rclone --config=${rcloneConfPath} sync ${ssdFolder} "$new_folder_name"

      ${pkgs.util-linux}/bin/umount ${hddBackupFolder}
    '';
  };
  systemd.services."${immichBackupServiceName}" = {
    description = "Backup immich database and media.";
    script = ''
      ${pkgs.rclone}/bin/rclone sync /var/lib/immich ${ssdFolder}/immich-backup/media
      ${pkgs.sudo}/bin/sudo -u postgres ${pkgs.postgresql}/bin/pg_dumpall --clean --if-exists > ${ssdFolder}/immich-backup/db.sql
      ${pkgs.coreutils}/bin/chown -R ${username} ${ssdFolder}/immich-backup
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
  systemd.services.copy-torrent-jellyfin = {
    script = ''
      ${copyMoviesAndShows}/bin/copy-movies-shows
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
  systemd.services."${remoteBackupServiceName}" = {
    script = ''
      ${pkgs.rclone}/bin/rclone sync /home/hugh/SSDs b2backup:thane-patrol-ironwolfs/
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "${username}";
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
  systemd.timers."${immichBackupServiceName}" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "1d";
      Unit = "backup-immich.service";
    };
  };
  systemd.timers.copy-torrent-jellyfin = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "5m";
      Unit = "copy-torrent-jellyfin.service";
    };
  };
  systemd.timers."${ssdBackupSystemdServiceName}" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "10m";
      OnUnitActiveSec = "1d";
      Unit = "${ssdBackupSystemdServiceName}.service";
    };
  };
  systemd.timers."${remoteBackupServiceName}" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1h";
      OnUnitActiveSec = "1w";
      Unit = "${remoteBackupServiceName}.service";
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
      wifi_password = { };
      latitude = { };
      longitude = { };
      time_zone = { };
      mosquitto_password = { };
      user_agent = { };
      wap_password = { };
      westo_iphone_mac = { };
      thane_fold_mac = { };
      grafana_secret_key = { };

      backblaze_key_id = {
        owner = "${username}";
      };
      backblaze_application_key = {
        owner = "${username}";
      };
      ipmi_password = { };
      gmail_app_password = { };
    };
    templates."ha-secrets.yaml" = {
      content = ''
        latitude: ${config.sops.placeholder.latitude}
        longitude: ${config.sops.placeholder.longitude}
        timeZone: ${config.sops.placeholder.time_zone}
      '';
      owner = "hass";
    };
    templates."zigbee2mqttsecrets.yaml" = {
      content = ''
        password: ${config.sops.placeholder.mosquitto_password}
      '';
      owner = "zigbee2mqtt";
    };
    templates."wap-env" = {
      content = ''
        WAP_PASSWORD_PAYLOAD="${config.sops.placeholder.wap_password}"
        USER_AGENT="${config.sops.placeholder.user_agent}"
        THANE_MAC=${config.sops.placeholder.thane_fold_mac}
        WESTO_MAC=${config.sops.placeholder.westo_iphone_mac}
        MQTT_PASSWORD=${config.sops.placeholder.mosquitto_password}
      '';
      owner = "${username}";
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
      /home/hugh/SSDs    10.0.0.3/24(insecure,rw,sync,no_subtree_check)
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
      1883 # Mosquitto
      2049
      2283 # immich
      3000 # general dev
      4000
      4001
      4002
      5055 # Jellyseer
      8123 # Home assistant
      8080 # Zigbee2Mqtt
      8888 # ledfx
      9090 # prometheus # TODO Not actually required. Just for debugging.
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
      8080 # Zigbee2Mqtt
      20048
      25565 # MC
    ];
  };

  security.rtkit.enable = true;
  services = {
    # Enable clipboard sharing to VM
    spice-vdagentd.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      audio.enable = true;
      pulse.enable = true;
      # extraConfig.pipewire."92-bluetooth-config" = {
      #   "context.modules" = [
      #     {
      #       name = "libpipewire-module-bluetooth5";
      #       args = { };
      #     }
      #   ];
      # };
      wireplumber.enable = true;
    };
  };

  # to allow swaylock to accept a password
  security.pam.services.swaylock = { };

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
      "bluetooth"
      "jellyfin"
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
