{ inputs, config, lib, pkgs, pkgs-unstable, ... }:
with import ./variables.nix { inherit config inputs pkgs lib; };
with lib;
let
  jmusicbot = "${serviceData}/jmusicbot";
  dashy_config = "${inputs.private}/configfiles/dashy.yml";
  tgtg_volume = "${serviceData}/tgtg";

  cockpit-machines = pkgs.callPackage ../packages/cockpit-machines.nix { };
in
{
  options.homelab = {
    enable = mkEnableOption ("Whether to enable homelab stuff");
    enablevps = mkEnableOption ("Whether to enable VPS homelab stuff");
  };

  config = mkMerge [
    (mkIf cfg.enable {
      services.cockpit = {
        enable = true;
        openFirewall = true;
        settings = {
          WebService = {
            Origins = "https://cockpit.${domain} wss://cockpit.${domain}";
            ProtocolHeader = "X-Forwarded-Proto";
          };
        };
      };
      environment.systemPackages = with pkgs; [
      ];
      systemd.tmpfiles.rules = [
        "d ${jmusicbot} 0755 root root"
      ];
      services.jmusicbot.enable = true;

      services.openvscode-server.enable = true;
      services.openvscode-server.user = "arnau";
      services.openvscode-server.port = 4444;
      services.openvscode-server.host = "0.0.0.0";

      networking.firewall.allowedTCPPorts = [
        #8123 HomeAssistant
        #8080 dashy
        #9090 cockpit
        #4444 code-server
        5900
        80 #caddy
        443 #caddy
      ];

      #Caddy reverse proxy
      services.caddy = {
        enable = true;
        package = pkgs.callPackage ../../packages/caddy-plugins.nix { };
        extraConfig = builtins.readFile ("${inputs.private}/configfiles/Caddyfile");
      };

      sops.secrets."duckdns/token".sopsFile = "${inputs.private}/secrets/sops/duckdns.env";
      sops.secrets."duckdns/token".format = "dotenv";

      systemd.services.caddy.serviceConfig = {
        EnvironmentFile = "${config.sops.secrets."duckdns/token".path}";
      };

      #Dashy
      virtualisation.oci-containers.backend = "docker";
      virtualisation.oci-containers.containers = {
        dashy = {
          image = "docker.io/lissy93/dashy:latest";
          ports = [
            "8080:80"
          ];
          volumes = [
            "${dashy_config}:/app/public/conf.yml:ro"
          ];
          extraOptions = commonextraOptions;

        };

      };


    })
    (mkIf cfg.enablevps {
      sops.secrets."tgtg/env" = {
        sopsFile = "${inputs.private}/secrets/sops/tgtg.env";
        format = "dotenv";
      };
      virtualisation.oci-containers.backend = "docker";
      virtualisation.oci-containers.containers = {
        tgtg = {
          image = "derhenning/tgtg:latest-alpine";

          environment = {
            TZ = "Europe/Madrid";
            LOCALE = "es_ES";
            SLEEP_TIME = "60";
            TELEGRAM = "true";
          };
          environmentFiles = [ "${config.sops.secrets."tgtg/env".path}" ];
          extraOptions = commonextraOptions;
          volumes = [
            "${tgtg_volume}:/tokens"
          ];
        };
      };


    })


  ];
}
