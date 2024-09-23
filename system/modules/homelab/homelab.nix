{ inputs, config, lib, pkgs, pkgs-unstable, secrets, private, ... }:
let
  vars = import ./variables.nix { inherit config inputs pkgs lib; };
  jmusicbot = "${vars.serviceData}/jmusicbot";
  tgtg_volume = "${vars.serviceData}/tgtg";

  cockpit-machines = pkgs.callPackage ../packages/cockpit-machines.nix { };
in
{
  options.homelab = {
    enable = lib.mkEnableOption "Whether to enable homelab stuff";
    enablevps = lib.mkEnableOption "Whether to enable VPS homelab stuff";
  };

  config = lib.mkMerge [
    (lib.mkIf vars.cfg.enable {
      virtualisation.oci-containers.backend = "docker";
      services.cockpit = {
        enable = false;
        openFirewall = true;
        settings = {
          WebService = {
            Origins = "https://cockpit.${secrets.domain} wss://cockpit.${secrets.domain}";
            ProtocolHeader = "X-Forwarded-Proto";
          };
        };
      };
      environment.systemPackages = [
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
        24680 #ventoy
        80 #caddy
        443 #caddy
      ];

      #Caddy reverse proxy
      services.caddy = {
        enable = true;
        package = pkgs.callPackage ../../packages/caddy-plugins.nix { };
        extraConfig = builtins.readFile "${private}/configfiles/Caddyfile";
      };
      age.secrets.duckdns.rekeyFile = private + "/secrets/age/duckdns.age";

      systemd.services.caddy.serviceConfig = {
        EnvironmentFile = "${config.age.secrets.duckdns.path}";
      };
    })
    (lib.mkIf vars.cfg.enablevps {
      age.secrets.tgtg.rekeyFile = "${private}/secrets/age/tgtg.age";
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
          environmentFiles = [ "${config.age.secrets.tgtg.path}" ];
          extraOptions = vars.commonextraOptions;
          volumes = [
            "${tgtg_volume}:/tokens"
          ];
        };
      };
    })
  ];
}
