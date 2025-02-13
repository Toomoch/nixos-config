{ inputs, config, lib, pkgs, secrets, private, self, ... }:
let
  jmusicbot = "${config.custom.homelab.serviceDataDir}/jmusicbot";
  tgtg_volume = "${config.custom.homelab.serviceDataDir}/tgtg";

  cfg = config.custom.homelab;
in {
  options.custom.homelab = {
    enable = lib.mkEnableOption "Whether to enable homelab stuff";
    enablevps = lib.mkEnableOption "Whether to enable VPS homelab stuff";
    serviceDataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib";
      description = "Base directory for service data";
    };
    primaryDomain = lib.mkOption {
      type = lib.types.str;
      default = secrets.hosts.${config.networking.hostName}.primaryDomain;
      description =
        "Domain that points to this host. Used to expose web services.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      virtualisation.oci-containers.backend = "docker";
      environment.systemPackages = [ ];
      systemd.tmpfiles.rules = [ ];

      networking.firewall.allowedTCPPorts = [
        80 # caddy
        443 # caddy
      ];

      #Caddy reverse proxy
      services.caddy = {
        enable = true;
        package = pkgs.caddy.withPlugins {
          plugins = [ "github.com/caddy-dns/duckdns@v0.4.0" "github.com/caddy-dns/desec@v0.0.0-20240526070323-822a6a2014b2"];
          hash = "sha256-YodaaxgUACqMqDNYHW7gStIp94LeGXWjKwrDW2kfogc=";
        };
      };
      age.secrets.duckdns.rekeyFile = /${private}/secrets/age/duckdns.age;

      systemd.services.caddy.serviceConfig = {
        EnvironmentFile = "${config.age.secrets.duckdns.path}";
      };
    })
    (lib.mkIf cfg.enablevps {
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
          extraOptions = [ "--pull=always" ];
          volumes = [ "${tgtg_volume}:/tokens" ];
        };
      };
    })
  ];
}
