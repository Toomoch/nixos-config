{
  pkgs,
  config,
  lib,
  self,
  ...
}:
let
  supportedExporters = [
    "node"
    "smartctl"
  ];

  autogenScrapeConfigs = lib.flatten (
    lib.map (
      exporterName:
      let
        staticConfigs = lib.filter (sc: sc != null) (
          lib.mapAttrsToList (
            hostname: host:
            let
              exporterConfig = host.config.services.prometheus.exporters.${exporterName};
            in
            if exporterConfig.enable or false then
              let
                ipAddress = lib.removeSuffix "/64" (
                  builtins.elemAt host.config.systemd.network.networks."50-metrics".address 0
                );
              in
              {
                targets = [ "[${ipAddress}]:${toString exporterConfig.port}" ];
                labels = {
                  instance = hostname;
                };
              }
            else
              null
          ) self.nixosConfigurations
        );
      in
      lib.optional (staticConfigs != [ ]) {
        job_name = exporterName;
        static_configs = staticConfigs;
      }
    ) supportedExporters
  );
in
{
  services.prometheus.alertmanager = {
    enable = false;
    configuration = {

    };
    webExternalUrl = "https://alerts.avalls.dev";

  };
  services.prometheus.exporters = {
    node = {
      enable = true;
    };
  };
  services.victoriametrics = {
    enable = true;
    retentionPeriod = "1y";
    extraOptions = [
      "-enableTCP6"
      "-vmalert.proxyURL=http://localhost${toString config.services.vmalert.settings."httpListenAddr"}"
    ];
    prometheusConfig.scrape_configs = autogenScrapeConfigs;
  };
  services.vmalert = {
    enable = true;
    rules = { };
    settings = {
      "datasource.url" =
        "http://localhost:${toString (lib.removePrefix ":" config.services.victoriametrics.listenAddress)}";
      "httpListenAddr" = ":8880";
    };
  };
  # networking.firewall.allowedTCPPorts = [
  #   (lib.toInt (lib.removePrefix ":" config.services.victoriametrics.listenAddress))
  # ];

  services.caddy = {
    enable = true;
    virtualHosts = {
      "metrics.avalls.dev" = {
        extraConfig = ''
          reverse_proxy localhost:${toString (lib.removePrefix ":" config.services.victoriametrics.listenAddress)}
        '';
      };
    };
  };

}
