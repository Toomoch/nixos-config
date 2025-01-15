{ inputs, pkgs, config, lib, secrets, ... }:
let cfg = config.custom.grafana;
in {
  options.custom.grafana.enable =
    lib.mkEnableOption "Whether to enable Grafana";

  config = lib.mkIf cfg.enable {
    services.grafana = {
      enable = true;
      settings.server.domain = "grafana.${config.custom.homelab.primaryDomain}";
    };
    services.prometheus = {
      enable = true;
      globalConfig.scrape_interval = "1m"; # "1m"
      scrapeConfigs = [{
        job_name = "node";
        static_configs = [{
          targets = [
            "localhost:${
              toString config.services.prometheus.exporters.node.port
            }"
          ];
        }];
      }];
    };
    services.prometheus.exporters.node = {
      enable = true;
      port = 9000;
      # https://github.com/NixOS/nixpkgs/blob/nixos-24.05/nixos/modules/services/monitoring/prometheus/exporters.nix
      enabledCollectors = [ "systemd" ];
      # /nix/store/zgsw0yx18v10xa58psanfabmg95nl2bb-node_exporter-1.8.1/bin/node_exporter  --help
      extraFlags =
        [ "--collector.ethtool" "--collector.softirqs" "--collector.tcpstat" ];
    };
    networking.firewall.allowedTCPPorts = [ 8428 ];

    services.victoriametrics = {
      enable = true;
      prometheusConfig = {
        scrape_configs = [{
          job_name = "telegraf";
          metrics_path = "/metrics";
          static_configs = [{
            targets = [
              "${secrets.hosts.rpi3.dns}:${
                toString config.custom.telegraf.prometheusPort
              }"
            ];
          }];
        }];
      };
    };
  };
}
