{ pkgs, config, ... }:

let
  prometheusPort = 9090;
  nodeExporterPort = 9091;
  textfileDir = "/var/lib/node_exporter/textfile_collector";
in
{
  services.prometheus = {
    enable = true;
    globalConfig = {
      scrape_interval = "15s";
      external_labels = {
        monitor = "codelab-monitor";
      };
    };
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
  };
  services.prometheus.exporters.node = {
    enable = true;
    port = nodeExporterPort;
    enabledCollectors = [ "textfile" ];
    disabledCollectors = [ "xfs" ];
    extraFlags = [ "--collector.textfile.directory=${textfileDir}" ];
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
}
