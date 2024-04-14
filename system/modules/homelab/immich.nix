{ inputs, pkgs, lib, config, ... }:
with import ./variables.nix { inherit config inputs pkgs lib; };
with lib;
let
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
    immich.enable = mkEnableOption ("Whether to enable immich stuff");
  };

  config = mkMerge [
    (mkIf cfg.immich.enable {

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
            TZ = timezone;
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
  ];
}
