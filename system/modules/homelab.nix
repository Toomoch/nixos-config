{ inputs, config, lib, pkgs, ... }:
with lib; let
  cfg = config.homelab;
  serviceData = # If host is h81, use the ZFS array 
    if config.networking.hostName == "h81" then
      "/zstorage/data"
    else
      "/var/lib";

  jmusicbot = "${serviceData}/jmusicbot";
  dashy_config = "${inputs.private}/configfiles/dashy.yml";
  hass_config = "${serviceData}/hass";
  tgtg_volume = "${serviceData}/tgtg";
  domain = "${builtins.readFile "${inputs.private}/secrets/plain/domain"}";
  commonextraOptions = [
    "--pull=always"
  ];

  cockpit-machines = pkgs.callPackage ../packages/cockpit-machines.nix { };

  immichNetwork = "immich-net";
  immichextraOptions = commonextraOptions ++ [ "--network=${immichNetwork}" ];

  immichRoot = "${serviceData}/immich";
  postgresRoot = "${immichRoot}/pgsql";
  postgresPassword = "testtest";
  postgresUser = "immich";
  postgresDb = "immich";
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

      services.homepage-dashboard.enable = true;

      #Caddy reverse proxy
      services.caddy = {
        enable = true;
        package = pkgs.callPackage ../packages/caddy-plugins.nix { };
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

        homeassistant = {
          image = "ghcr.io/home-assistant/home-assistant:stable";
          ports = [
            "8123:8123"
          ];
          volumes = [
            "${hass_config}:/config:Z"
          ];
          environment = {
            TZ = "Europe/Madrid";
          };
          extraOptions = commonextraOptions ++ [
            "--network=host"
            "--device=/dev/serial/by-id/usb-1a86_USB_Serial-if00-port0:/dev/ttyUSB0:rw"
          ];

        };
      };

      # Immich Network
      systemd.services.init-filerun-network-and-files =
        {
          description = "Create the network bridge for Immich.";
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];

          serviceConfig.Type = "oneshot";
          script =
            let dockercli = "${config.virtualisation.docker.package}/bin/docker";
            in ''
              # immich-net network
              check=$(${dockercli} network ls | grep "${immichNetwork}" || true)
              if [ -z "$check" ]; then
                ${dockercli} network create ${immichNetwork}
              else
                echo "${immichNetwork} already exists in docker"
              fi
            '';
        };

      # Immich
      virtualisation.oci-containers.containers = {
        immich = {
          autoStart = true;
          image = "ghcr.io/imagegenius/immich:latest";
          volumes = [
            "${immichRoot}/config:/config"
            "${immichRoot}/photos:/photos"
          ];
          ports = [ "2283:8080" ];
          environment = {
            PUID = "1000";
            PGID = "100";
            TZ = "Europe/Madrid";
            DB_HOSTNAME = "postgres14";
            DB_USERNAME = postgresUser;
            DB_PASSWORD = postgresPassword;
            DB_DATABASE_NAME = postgresDb;
            REDIS_HOSTNAME = "redis";
          };
          extraOptions = immichextraOptions;
        };

        redis = {
          autoStart = true;
          image = "redis";
          ports = [ "6379:6379" ];
          extraOptions = immichextraOptions;
        };

        postgres14 = {
          autoStart = true;
          image = "tensorchord/pgvecto-rs:pg14-v0.2.0";
          ports = [ "5432:5432" ];
          volumes = [
            "${postgresRoot}:/var/lib/postgresql/data"
          ];
          environment = {
            POSTGRES_USER = postgresUser;
            POSTGRES_PASSWORD = postgresPassword;
            POSTGRES_DB = postgresDb;
          };
          extraOptions = immichextraOptions;
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
