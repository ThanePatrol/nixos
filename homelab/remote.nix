{
  pkgs,
  config,
  ports,
  ...
}:

let
  remote = pkgs.rustPlatform.buildRustPackage {
    pname = "remote";
    version = "0.1.0";
    src = ./remote;
    cargoLock.lockFile = ./remote/Cargo.lock;
  };

in
{
  users.users.tv-remote = {
    isSystemUser = true;
    group = "tv-remote";
    description = "TV remote web service";
  };
  users.groups.tv-remote = { };

  sops.templates."remote-env" = {
    content = ''
      MQTT_USERNAME=iot
      MQTT_PASSWORD=${config.sops.placeholder.mosquitto_password}
    '';
    owner = "tv-remote";
    mode = "0400";
  };

  systemd.services.tv-remote = {
    description = "Web-based TV remote (publishes IR commands over MQTT)";
    after = [
      "network.target"
      "mosquitto.service"
    ];
    wants = [ "mosquitto.service" ];
    wantedBy = [ "multi-user.target" ];
    environment = {
      MQTT_BROKER = "mqtt://127.0.0.1:${toString ports.openFirewall.mosquitto}";
      REMOTE_LISTEN_ADDR = "0.0.0.0:${toString ports.noFirewall.tvRemote}";
      RUST_LOG = "remote=info,warn";
    };
    serviceConfig = {
      ExecStart = "${remote}/bin/remote";
      EnvironmentFile = config.sops.templates."remote-env".path;
      User = "tv-remote";
      Group = "tv-remote";
      Restart = "on-failure";
      RestartSec = 5;

      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      ProtectControlGroups = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [ ports.noFirewall.tvRemote ];
}
