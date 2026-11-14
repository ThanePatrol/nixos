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
  foldersToBackup = [
    "/home/hugh/.config/sops"
  ];
  hddBackupFolder = "/home/hugh/Backups";
  ssdBackupSystemdServiceName = "backup-local";
  immichBackupServiceName = "backup-immich";

  serviceNamesToMonitor = [
    ssdBackupSystemdServiceName
    immichBackupServiceName
    "get-connected-clients"
  ];

  _tenGbEthernetPort1 = "enp36s0f0"; # physically the bottom port
  _tenGbEthernetPort2 = "enp36s0f1";
  _onboardGigabitEthernetPort1 = "enp38s0";
  _onboardGigabitEthernetPort2 = "enp39s0"; # physically the bottom port
  _managementPort = "enp42s0f3u5u3c2";

  theme = "Catppuccin-mocha";
  ports = {
    exposeProxy = {
      # keep-sorted start numeric=yes
      blog = {
        port = 1313;
        hostname = "blog.mandalidis.com";
      };
      forgejo = {
        port = 3005;
        hostname = "git.mandalidis.com";
      };
      grafanaPort = {
        port = 3001;
        hostname = "grafana.mandalidis.com";
      };
      homeAssistant = {
        port = 8123;
        hostname = "home.mandalidis.com";
      };
      immich = {
        port = 2283;
        hostname = "immich.mandalidis.com";
      };
      jellyfin = {
        port = 8096;
        hostname = "jellyfin.mandalidis.com";
      };
      paperless = {
        port = 8870;
        hostname = "paperless.mandalidis.com";
      };
      pihole = {
        port = 3002;
        hostname = "pihole.mandalidis.com";
      };
      pingoraLogin = {
        port = 8443;
        hostname = "login.mandalidis.com";
      };
      qbittorrent = {
        port = 8010;
        hostname = "torrent.mandalidis.com";
      };
      ttyd = {
        port = 3004;
        hostname = "terminal.mandalidis.com";
      };
      zigbee2MQTT = {
        port = 8080;
        hostname = "zigbee.mandalidis.com";
      };
      # keep-sorted end
    };
    # Note firewall in this context is just for other devices on LAN.
    # Only 443 is exposed to internet.
    openFirewall = {
      # keep-sorted start numeric=yes
      dev = 3000;
      minecraft = 25565;
      mosquitto = 1883;
      nfsAcl = 2049;
      nfsLockd = 4001;
      nfsMountd = 4002;
      nfsMountdRpc = 20048;
      nfsPortmapper = 111;
      nfsStatd = 4000;
      ssl = 443;
      # keep-sorted end
    };
    noFirewall = {
      # keep-sorted start numeric=yes
      llamaServer = 9000;
      nodeExporterPort = 9091;
      pingoraPrometheus = 8442;
      processExporter = 9256;
      prometheusPort = 9090;
      tvRemote = 8099;

      # keep-sorted end
    };
  };

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

  copyMoviesAndShows = pkgs.writeShellScriptBin "copy-movies-shows" ''
      set -euox

      while IFS= read -r -d "" file; do
        # Check if file exists in jellyfin dir already

        prompt='{
          "messages": [
            {"role": "system", "content": "You are a specialized media management assistant. Identify whether the provided file is a Movie or a TV show. Output ONLY movie or show No explanations or chatter."},
            {"role": "user", "content": "@@PROMPT"}
          ],
          "temperature": 0,
          "max_tokens": 64
        }'


        prompt="$(echo "$prompt" | sed 's/@@PROMPT/movie')"
        echo "$prompt"

        out="$(curl -s localhost:9000/v1/chat/completions \
          -H 'Content-Type: application/json' \
          -d "$prompt" | jq -r '.choices[0].message.content')"
        # TODO: Extract this out into a function
        # TODO: Rewrite as python script:
    #     pkgs.writers.writePython3Bin "my-nix-script" 
    # {
    #   # Pass external Python library dependencies here
    #   libraries = with pkgs.python3Packages; [ 
    #     requests 
    #     beautifulsoup4 
    #   ];
    # } 
    #   import requests
    #   from bs4 import BeautifulSoup
    #
    #   print("Fetching data from NixOS Wiki...")
    #   response = requests.get("https://nixos.wiki/")
    #
    #   if response.status_code == 200:
    #       soup = BeautifulSoup(response.text, 'html.parser')
    #       print(f"Page Title: {soup.title.string}")
    #   else:
    #       print("Failed to fetch the webpage.")



        if rg -q 'show' <<< $out ; then
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
    ../../homelab/home-assistant.nix
    ../../homelab/monitoring.nix
    ../../homelab/remote.nix
    ../../homelab/proxy.nix
    # ../../homelab/pihole.nix
    ../../homelab/blog.nix
  ];
  _module.args = {
    toMonitor = serviceNamesToMonitor;
    ports = ports;
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.trusted-users = [
    "root"
    "hugh"
    "iw"
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
    cpu.amd = {
      updateMicrocode = true;
    };
    keyboard = {
      qmk.enable = true;
    };
  };

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  services.qbittorrent = {
    enable = true;
    webuiPort = ports.exposeProxy.qbittorrent.port;
    openFirewall = true;
  };

  services.llama-cpp = {
    enable = true;
    settings = {
      port = ports.noFirewall.llamaServer;
      sleep-idle-seconds = 500;
      n-predict = 256;
      hf-repo = "unsloth/gemma-4-E4B-it-GGUF";
    };
  };

  systemd.services."${ssdBackupSystemdServiceName}" = {
    description = "Mount HDD and backup files";
    script = ''
      set -euxo pipefail
      if [ ! -d ${hddBackupFolder} ]; then
        ${pkgs.coreutils}/bin/mkdir ${hddBackupFolder}
      fi

      if ${pkgs.gnugrep}/bin/grep -qs " ${hddBackupFolder} " /proc/mounts; then
        echo "file system already mounted"
      else
        ${pkgs.util-linux}/bin/mount -o noatime,nodev,nosuid,noexec -t ext4 /dev/disk/by-uuid/70f28b15-ef28-40ba-be2d-3cccd40fd85c ${hddBackupFolder}
        ${pkgs.coreutils}/bin/chown -R ${username} ${hddBackupFolder}
        echo "mounted hdds"
      fi

      # Move other files not stored on SSDs into the SSD folder that is backed up.
      for f in ${builtins.concatStringsSep " " foldersToBackup}; do
        folder_name="${ssdFolder}$f"
        ${pkgs.coreutils}/bin/mkdir -p $folder_name
        ${pkgs.coreutils}/bin/cp -r $f $folder_name
      done

      new_folder_name=${hddBackupFolder}/"backup-$(${pkgs.coreutils}/bin/date -u +%Y-%m-%d_%H.%M.%S%Z)"
      ${pkgs.coreutils}/bin/mkdir "$new_folder_name"
      # remove all but the latest dir, if less than 3 do nothing - assume no other files in here!
      # Relies upon sorting by date and head -n -3 not showing anything if less than 3.
      ${pkgs.coreutils}/bin/ls ${hddBackupFolder} | ${pkgs.coreutils}/bin/sort | ${pkgs.coreutils}/bin/head -n -3 | ${pkgs.findutils}/bin/xargs -I {} ${pkgs.coreutils}/bin/rm -r ${hddBackupFolder}/{} || true
      ${pkgs.coreutils}/bin/echo "Removed old backups"

      # prevent shutdown until backup finishes
      ${pkgs.systemd}/bin/systemd-inhibit --why="backing up ssds! 😋" ${pkgs.rclone}/bin/rclone --config=${rcloneConfPath} sync ${ssdFolder} "$new_folder_name"

      ${pkgs.systemd}/bin/systemd-inhibit --why="backing up remote! 😋" ${pkgs.rclone}/bin/rclone --config=${rcloneConfPath} sync "$new_folder_name/" b2backup:thane-patrol-ironwolfs/

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
  systemd.services.download-hsbc = {
    script = ''
      ${pkgs.nix}/bin/nix develop /home/hugh/dev/finance -c ${pkgs.bash}/bin/bash -c 'make fresh-vnc-debug && sleep 10 && make hsbc-download'
    '';
    serviceConfig = {
      WorkingDirectory = "/home/hugh/dev/finance";
      User = "hugh";
    };
  };

  systemd.services.cloudflare-ddns = {
    script = ''
      source ${config.sops.templates."cloudflare-env".path}
      external_ip="$(${pkgs.curl}/bin/curl ifconfig.me)"

      function send_for_domain() {
        domain="$1"
        id="$2"
        content="$3"
        payload_param='{
          "name": "@@DOMAIN",
          "ttl": 1,
          "type": "A",
          "comment": "Domain verification record",
          "content": "@@CONTENT",
          "proxied": true
        }'
        payload="$(echo $payload_param | ${pkgs.gnused}/bin/sed "s/@@DOMAIN/$domain/")"
        payload="$(echo $payload | ${pkgs.gnused}/bin/sed "s/@@CONTENT/$external_ip/")"
        ${pkgs.curl}/bin/curl "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$id" \
          -X PUT \
          -H 'Content-Type: application/json' \
          -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
          -d "$(echo $payload)"

      }
      main_domain="login.mandalidis.com"
      main_domain_id="$(echo $LOGIN_DNS_RECORD_ID)"

      send_for_domain "$main_domain" "$main_domain_id" 
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
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
  systemd.timers.cloudflare-ddns = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "20s";
      OnUnitActiveSec = "5m";
      Unit = "cloudflare-ddns.service";
    };
  };
  # systemd.timers.copy-torrent-jellyfin = {
  #   wantedBy = [ "timers.target" ];
  #   timerConfig = {
  #     OnBootSec = "5m";
  #     OnUnitActiveSec = "5m";
  #     Unit = "copy-torrent-jellyfin.service";
  #   };
  # };
  systemd.timers."${ssdBackupSystemdServiceName}" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "10m";
      OnUnitActiveSec = "1d";
      Unit = "${ssdBackupSystemdServiceName}.service";
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
      "9.9.9.9"
      "149.112.112.112"
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
      thane_pixel_mac = { };
      grafana_secret_key = { };

      backblaze_key_id = {
        owner = "${username}";
      };
      backblaze_application_key = {
        owner = "${username}";
      };
      ipmi_password = { };
      gmail_app_password = { };
      cloudflare_certbot_api_key = { };
      cloudflare_api_key = { };
      cloudflare_account_id = { };
      cloudflare_zone_id = { };
      cloudflare_login_dns_record_id = { };
      google_client_id = { };
      google_client_secret = { };
      google_redirect_uri = { };
      allowed_emails = { };
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
        THANE_MAC=${config.sops.placeholder.thane_pixel_mac}
        WESTO_MAC=${config.sops.placeholder.westo_iphone_mac}
        MQTT_PASSWORD=${config.sops.placeholder.mosquitto_password}
      '';
      owner = "${username}";
    };
    templates."cloudflare-env" = {
      content = ''
        ZONE_ID=${config.sops.placeholder.cloudflare_zone_id}
        LOGIN_DNS_RECORD_ID=${config.sops.placeholder.cloudflare_login_dns_record_id}
        CLOUDFLARE_API_TOKEN=${config.sops.placeholder.cloudflare_api_key}
      '';
    };
  };

  programs = {
    nix-ld.enable = true;
    zsh.enable = true;
    dconf.enable = true;
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
      /home/hugh/SSDs    10.0.0.3/24(insecure,rw,sync,no_subtree_check,all_squash,anonuid=1000,anongid=1000)
    '';
    lockdPort = ports.openFirewall.nfsLockd;
    mountdPort = ports.openFirewall.nfsMountd;
    statdPort = ports.openFirewall.nfsStatd;
  };
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      # keep-sorted start
      ports.exposeProxy.homeAssistant.port # Home assistant
      ports.exposeProxy.immich.port # immich
      ports.exposeProxy.paperless.port # Paperless
      ports.exposeProxy.pihole.port # web ui for pihole.
      ports.exposeProxy.zigbee2MQTT.port # Zigbee2Mqtt
      ports.openFirewall.dev # general dev
      ports.openFirewall.minecraft # Minecraft
      ports.openFirewall.mosquitto # Mosquitto
      ports.openFirewall.nfsAcl # NFS acl
      ports.openFirewall.nfsLockd # NFS nlockmgr
      ports.openFirewall.nfsMountd # NFS mountd
      ports.openFirewall.nfsMountdRpc # NFS port
      ports.openFirewall.nfsPortmapper # NFS portmapper
      ports.openFirewall.nfsStatd # NFS status
      ports.openFirewall.ssl # SSL for Pingora.
      # keep-sorted end
    ];
    allowedUDPPorts = [
      # keep-sorted start
      ports.openFirewall.minecraft # Minecraft
      ports.openFirewall.nfsAcl # NFS acl
      ports.openFirewall.nfsLockd # NFS nlockmgr
      ports.openFirewall.nfsMountd # NFS mountd
      ports.openFirewall.nfsMountdRpc # NFS port
      ports.openFirewall.nfsPortmapper # NFS portmapper
      ports.openFirewall.nfsStatd # NFS status
      # keep-sorted end
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
      wireplumber.enable = true;
    };
  };

  home-manager.useGlobalPkgs = true;
  home-manager.users = {
    ${username} = homeConfig;
    "iw" = ../../home/iw/home.nix;
  };

  # Add group for /var/www/html/blog/ ownership
  users.groups.bloggers = { };

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
        "jellyfin"
        "bloggers"
      ];
      shell = pkgs.zsh;
    };
    "iw" = {
      isNormalUser = true;
      description = "iw";
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
        "bloggers"
      ];
      shell = pkgs.zsh;
    };
  };

  environment.systemPackages = syspackages.environment.systemPackages;

  environment.pathsToLink = [
    "/share/zsh"
    "/share/icons" # For Xournalpp not finding icons
    "/share/mime" # https://github.com/NixOS/nixpkgs/issues/163107
  ];

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu.package = pkgs.qemu;
    };
  };

  services.ttyd = {
    enable = true;
    port = ports.exposeProxy.ttyd.port;
    writeable = true;
    maxClients = 1;
  };

  services.forgejo = {
    enable = true;
    lfs.enable = true;
    settings = {
      server = {
        ROOT_URL = "https://${ports.exposeProxy.forgejo.hostname}/";
        HTTP_PORT = ports.exposeProxy.forgejo.port;
      };
    };
    # TODO: Setup runners with services.forgejo-runner
    # actions = {
    #   ENABLED = true;
    #   DEFAULT_ACTIONS_URL = "github";
    # };
  };

  services.paperless = {
    enable = true;
    port = ports.exposeProxy.paperless.port;
    address = "0.0.0.0";
    consumptionDirIsPublic = true;
    settings = {
      PAPERLESS_CONSUMER_SUBDIRS_AS_TAGS = true;
      PAPERLESS_OCR_LANGUAGE = "eng";
      PAPERLESS_CONSUMER_RECURSIVE = true;
      PAPERLESS_URL = "https://${ports.exposeProxy.paperless.hostname}";
      PAPERLESS_CSRF_TRUSTED_ORIGINS = "https://${ports.exposeProxy.paperless.hostname}";
    };
  };

  services.immich = {
    enable = true;
    port = ports.exposeProxy.immich.port;
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
