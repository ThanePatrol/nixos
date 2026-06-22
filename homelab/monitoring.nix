{
  pkgs,
  lib,
  config,
  toMonitor,
  ...
}:

let
  prometheusPort = 9090;
  nodeExporterPort = 9091;
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
            targets = [ "localhost:${toString prometheusPort}" ];
          }
        ];
      }
      {
        job_name = "asrock";
        scrape_interval = "5s";
        static_configs = [
          {
            targets = [ "localhost:${toString nodeExporterPort}" ];
          }
        ];
      }
    ];
    ruleFiles = [
      ./rules/systemd-backups.yaml
    ];
  };

  # TODO setup alerting on `node_systemd_unit_state{name=~".*service", state="failed"} == 1`
  # to be aware of failed backups.
  services.prometheus.exporters.node = {
    enable = true;
    port = nodeExporterPort;
    enabledCollectors = [ "textfile" ];
    disabledCollectors = [ "xfs" ];
    extraFlags = [
      "--collector.textfile.directory=${textfileDir}"
      "--collector.systemd"
      ''--collector.systemd.unit-include="(${lib.concatStringsSep "|" toMonitor}).(service|timer)"''
      "--collector.systemd.enable-start-time-metrics"
      "--collector.systemd.enable-task-metrics"
      "--collector.systemd.enable-restarts-metrics"
    ];
  };
  # Override to allow node exporter to use dbus.
  systemd.services.prometheus-node-exporter.serviceConfig.RestrictAddressFamilies = [ "AF_UNIX" ];

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
}
