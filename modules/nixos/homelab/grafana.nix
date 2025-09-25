{ inputs, pkgs, config, lib, secrets, ... }:
let
  cfg = config.custom.grafana;
in { options.custom.grafana.enable =
    lib.mkEnableOption "Whether to enable Grafana";

  config = lib.mkIf cfg.enable {
    services.grafana = {
      enable = false;
      settings.server.domain = "grafana.${config.custom.homelab.primaryDomain}";
      settings.server.root_url = "https://%(domain)s:443/";
    };

    services.caddy.virtualHosts."grafana.${config.custom.homelab.primaryDomain}" =
      {
        extraConfig = ''
          reverse_proxy localhost:${
            toString config.services.grafana.settings.server.http_port
          }
        '';
      };


  };
}
