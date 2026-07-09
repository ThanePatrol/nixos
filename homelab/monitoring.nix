{
  pkgs,
  lib,
  config,
  toMonitor,
  ports,
  ...
}:

let
  textfileDir = "/var/lib/node_exporter/textfile_collector";
in
{

  environment.systemPackages = [ pkgs.prometheus-alertmanager ];
  services.prometheus = {
    enable = true;
    globalConfig = {
      scrape_interval = "15s";
      external_labels = {
        monitor = "codelab-monitor";
      };
    };
    retentionTime = "365d";
    extraFlags = [ "--storage.tsdb.retention.size=100GB" ];
    scrapeConfigs = [
      {
        job_name = "prometheus";
        scrape_interval = "5s";
        static_configs = [
          {
            targets = [ "localhost:${toString ports.noFirewall.prometheusPort}" ];
          }
        ];
      }
      {
        job_name = "asrock";
        scrape_interval = "5s";
        static_configs = [
          {
            targets = [ "localhost:${toString ports.noFirewall.nodeExporterPort}" ];
          }
        ];
      }
    ];
    ruleFiles = [
      ./rules/systemd-backups.yaml
      ./rules/alerting.yaml
    ];
  };

  # TODO setup alerting on `node_systemd_unit_state{name=~".*service", state="failed"} == 1`
  # to be aware of failed backups.
  services.prometheus.exporters.node = {
    enable = true;
    port = ports.noFirewall.nodeExporterPort;
    enabledCollectors = [ "textfile" ];
    disabledCollectors = [ "xfs" ];
    extraFlags = [
      "--collector.textfile.directory=${textfileDir}"
      "--collector.systemd"
      ''--collector.systemd.unit-include="(${lib.concatStringsSep "|" toMonitor}).(service|timer)"''
      "--collector.systemd.enable-start-time-metrics"
      "--collector.systemd.enable-task-metrics"
      "--collector.systemd.enable-restarts-metrics"
      "--collector.filesystem.mount-points-include=^(/|/home/hugh/SSDs|/nix/store)$"
      "--collector.filesystem.fs-types-include=^(xfs|btrfs|ext4)$"
    ];
  };
  systemd.services.prometheus-node-exporter.serviceConfig = {
    # Override to allow node exporter to use dbus.
    RestrictAddressFamilies = [ "AF_UNIX" ];
  };

  systemd.services.export-ipmi = {
    script = ''
      password="$(cat ${config.sops.secrets.ipmi_password.path})"
      tmp="/tmp/$(${pkgs.coreutils}/bin/date +\%s).prom"
      ${pkgs.curl}/bin/curl -s -k -u admin:$password https://10.0.0.2/redfish/v1/Chassis/Self/Thermal |
      ${pkgs.jq}/bin/jq -r '.Temperatures.[]
        | select(.Status.State != "Absent")
        | select(.ReadingCelsius != null)
        | .Name |= gsub("\\s+"; "_")
        | .Name |= ascii_downcase
        | (
          "# HELP redfish_temperature_celsius_\(.Name) Temperature reading with max of \(.UpperThresholdNonCritical)",
          "# TYPE redfish_temperature_celsius_\(.Name) gauge",
          "redfish_temperature_celsius{sensor=\"\(.Name)\"} \(.ReadingCelsius)"
        )
      ' > "$tmp"

      ${pkgs.coreutils}/bin/chmod 0644 "$tmp"
      ${pkgs.coreutils}/bin/mv "$tmp" ${textfileDir}/redfish_thermal.prom
      ${pkgs.coreutils}/bin/rm "$tmp" || true;
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root"; # Ideally we would use DynamicUser but it's a PITA to set up the dynamic user to read the sops secret.
    };
  };
  systemd.timers.export-ipmi = {
    description = "Export IPMI information every minute";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1m";
      OnUnitActiveSec = "1m";
      Unit = "export-ipmi.service";
    };
  };

  sops.templates."alertmanager".content = ''
    GMAIL_APP_PASSWORD=${config.sops.placeholder.gmail_app_password}
  '';
  services.prometheus.alertmanager = {
    enable = true;
    environmentFile = config.sops.templates.alertmanager.path;

    configuration = {
      global = {
        resolve_timeout = "5m";
        smtp_smarthost = "smtp.gmail.com:587";
        smtp_from = "mandalidis.hugh@gmail.com";
        smtp_auth_username = "mandalidis.hugh@gmail.com";
        smtp_auth_password = "$GMAIL_APP_PASSWORD";
      };
      route = {
        receiver = "email";
        group_by = [ "..." ];
        group_wait = "30s";
        group_interval = "5m";
        repeat_interval = "4h";
      };
      receivers = [
        {
          name = "email";
          email_configs = [
            {
              to = "mandalidis.hugh@gmail.com";
              send_resolved = true;
            }
            {
              to = "iweston1702@gmail.com";
              send_resolved = true;
            }
          ];
        }
      ];
    };
  };
  services.prometheus.alertmanagers = [
    {
      static_configs = [
        { targets = [ "localhost:${toString config.services.prometheus.alertmanager.port}" ]; }
      ];
    }
  ];

  services.grafana = {
    enable = true;
    openFirewall = true;
    settings = {
      security.secret_key = "${config.sops.placeholder.grafana_secret_key}";
      server = {
        http_port = ports.openFirewall.grafanaPort;
        http_addr = "0.0.0.0";
      };
    };
    provision = {
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          uid = "prometheus";
          access = "proxy";
          url = "http://localhost:${toString ports.noFirewall.prometheusPort}";
          isDefault = true;
        }
      ];
      dashboards.settings.providers = [
        {
          name = "homelab";
          type = "file";
          options.path = ./dashboards;
          # Disable so deletes in Grafana UI don't get auto-restored mid-session;
          # set to true if you want strict file-as-source-of-truth.
          disableDeletion = true;
          allowUiUpdates = false;
        }
      ];
    };

  };
  # TODO - Setup process monitor.
  services.prometheus.exporters.process = {
    enable = true;
    port = ports.noFirewall.processExporter;
  };

  # TODO - Add grafana dashboards for:
  # 1. [ ] WAN traffic - need something on router
  # 2. [ ] WAN throughput per host - need something on router
  # 3. [x] Disk usage per partition
  # 4. [ ] Disk health per partition - need smartctl_exporter
  # 5. [x] CPU usage
  # 6. [x] CPU temp
  # 7. [ ] Power usage - need to scrape redfish /Power
  # 8. [ ] CPU usage per process - need process-exporter instrumentation
  # 9. [x] RAM usage
  # 11 [x]. Network/LAN throughput
  # 12 [ ]. Network/LAN throughput per process - need process-exporter instrumentation
  # 13 [ ]. Current client count - need something on router
  # 14 [ ]. Ads blocked - need something on router

}
