{
  pkgs,
  config,
  lib,
  self,
  ...
}:
{
  services.prometheus.alertmanager = {
    enable = false;
    configuration = {

    };
    webExternalUrl = "https://alerts.avalls.dev";

  };
  services.victoriametrics = {
    enable = true;
    retentionPeriod = "1y";
    # prometheusConfig = {
    #   scrape_configs = [
    #     {
    #       job_name = "postgres-exporter";
    #       metrics_path = "/metrics";
    #       static_configs = [
    #         {
    #           targets = ["1.2.3.4:9187"];
    #           labels.type = "database";
    #         }
    #       ];
    #     }
    #     {
    #       job_name = "node-exporter";
    #       metrics_path = "/metrics";
    #       static_configs = [
    #         {
    #           targets = ["1.2.3.4:9100"];
    #           labels.type = "node";
    #         }
    #         {
    #           targets = ["5.6.7.8:9100"];
    #           labels.type = "node";
    #         }
    #       ];
    #     }
    #   ];
    # }
    # ;
    prometheusConfig.scrape_configs =
      let
        # If we don't do this,
        # evaluating prometheus-server.config would require prometheus-server.config .....
        otherHosts = lib.filterAttrs (
          name: host: name != config.networking.hostName && host.config.custom.prometheus.enable
        ) self.nixosConfigurations;

        remoteExporters = lib.flatten (
          map (host: host.config.custom.prometheus.exporters) (lib.attrValues otherHosts)
        );

        localExporters = config.custom.prometheus.exporters;

        allExporters = localExporters ++ remoteExporters;

        groupedExporters = lib.groupBy (exporter: exporter.job) allExporters;

      in
      lib.mapAttrsToList (jobName: exportersForJob: {
        job_name = jobName;
        static_configs = [
          {
            targets = map (exporter: "${exporter.hostname}:${toString exporter.port}") exportersForJob;
          }
        ];
      }) groupedExporters;
  };

}
