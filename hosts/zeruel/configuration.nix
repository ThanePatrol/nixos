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
  homeAssistantConfig = import ../../homelab/home-assistant.nix {
    inherit
      pkgs
      config
      ;
  };
  monitoringConfig = import ../../homelab/monitoring.nix {
    inherit
      pkgs
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
      for file in $(${pkgs.findutils}/bin/find /var/lib/qBittorrent/qBittorrent/downloads/ -type f -not -path "/var/lib/qBittorrent/qBittorrent/downloads/temp/*" | ${pkgs.ripgrep}/bin/rg '\.(mp4|mkv)'); do
        if ${pkgs.ripgrep}/bin/rg -q "(s|S)\d+.*(e|E)\d+" "$file"; then
          ${pkgs.rsync}/bin/rsync -azvP "$file" /var/lib/jellyfin/Shows
        else
          ${pkgs.rsync}/bin/rsync -azvP "$file" /var/lib/jellyfin/Movies
        fi
      done
    ${pkgs.coreutils}/bin/chown -R jellyfin /var/lib/jellyfin
  '';

  syspackages = import ../../system/linux/packages/packages.nix { inherit pkgs; };
in
{
  imports = [
    ./hardware-configuration.nix
    ../../homelab/proxmox.nix

  ];
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
  systemd.services.backup-immich = {
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
  systemd.services.get-connected-clients = {
    description = "Get clients connected to WAP";
    serviceConfig = {
      StateDirectory = "wap-presence";
      StateDirectoryMode = "0755"; # world-readable
      UMask = "0022"; # files written are 0644
    };
    script = ''
      source ${config.sops.templates."wap-env".path}
      cookie_path="/tmp/wap_cookie.txt"

      function login() {
          ${pkgs.curl}/bin/curl -sS 'http://10.0.0.242/' \
            -X POST \
            -H "$USER_AGENT" \
            -H 'Accept: application/json, text/javascript, */*; q=0.01' \
            -H 'Accept-Language: en-US,en;q=0.9' \
            -H 'Accept-Encoding: gzip, deflate' \
            -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' \
            -H 'X-Requested-With: XMLHttpRequest' \
            -H 'Origin: http://10.0.0.242' \
            -H 'DNT: 1' \
            -H 'Connection: keep-alive' \
            -H 'Referer: http://10.0.0.242/logout.html' \
            -H 'Priority: u=0' \
            --data-raw "$WAP_PASSWORD_PAYLOAD" -c "$cookie_path"
      }

      function fetch_clients_raw() {
          ${pkgs.curl}/bin/curl -sS 'http://10.0.0.242/data/status.client.user.json?operation=load&_=1779879188339' \
            -H "$USER_AGENT" \
            -H 'Accept: application/json, text/javascript, */*; q=0.01' \
            -H 'Accept-Language: en-US,en;q=0.9' \
            -H 'Accept-Encoding: gzip, deflate' \
            -H 'X-Requested-With: XMLHttpRequest' \
            -H 'DNT: 1' \
            -H 'Connection: keep-alive' \
            -H 'Referer: http://10.0.0.242/' \
            -b "$cookie_path"
      }

      function get_connected_devices() {
          local response
          response=$(fetch_clients_raw)

          local status
          status=$(echo "$response" | ${pkgs.jq}/bin/jq -r '.status // -1')

          if [ "$status" = "-1" ]; then
              login >/dev/null
              response=$(fetch_clients_raw)
          fi

          local match
          match=$(echo "$response" | ${pkgs.jq}/bin/jq --arg a "$WESTO_MAC" --arg b "$THANE_MAC" \
              '[.data[]? | select(.MAC | IN($a, $b))] | length')

          if [ "$match" -gt 0 ]; then
            ${pkgs.mosquitto}/bin/mosquitto_pub -h localhost -t "wap/presence" -m "true" -u iot -P "$MQTT_PASSWORD" -r 
          else
            ${pkgs.mosquitto}/bin/mosquitto_pub -h localhost -t "wap/presence" -m "false" -u iot -P "$MQTT_PASSWORD" -r 
          fi
      }

      get_connected_devices
    '';
  };
  systemd.services.run-remote-backup = {
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
  systemd.timers.backup-immich = {
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
  systemd.timers.get-connected-clients = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5s";
      OnUnitActiveSec = "5s";
      Unit = "get-connected-clients.service";
    };
  };
  systemd.timers.init-backup = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "10m";
      OnUnitActiveSec = "1d";
      Unit = "${ssdBackupSystemdServiceName}.service";
    };
  };
  systemd.timers.run-remote-backup = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1h";
      OnUnitActiveSec = "1w";
      Unit = "run-remote-backup.service";
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
      backblaze_key_id = {
        owner = "${username}";
      };
      backblaze_application_key = {
        owner = "${username}";
      };
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

  # TODO: Surely there's a better way?
  services.home-assistant = homeAssistantConfig.services.home-assistant;
  services.mosquitto = homeAssistantConfig.services.mosquitto;
  services.zigbee2mqtt = homeAssistantConfig.services.zigbee2mqtt;

  services.prometheus = monitoringConfig.services.prometheus;

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
