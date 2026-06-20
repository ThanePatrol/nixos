{ pkgs, ... }:

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
            targets = [ "localhost:9090" ];
          }
        ];
      }
    ];
  };
}
