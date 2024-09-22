{ inputs, pkgs, lib, config, secrets, private, ... }:
let
  vars = import ./variables.nix { inherit config inputs pkgs lib secrets; };
  dataBase = "${vars.serviceData}/postgresql/${config.services.postgresql.package.psqlSchema}";
  pgBackups = "${vars.serviceData}/backups/postgresql";
  ncHome = "${vars.serviceData}/nextcloud";
in
{

  options.homelab = {
    nextcloud.enable = lib.mkEnableOption "Whether to enable Nextcloud";
  };

  config = lib.mkIf vars.cfg.nextcloud.enable {
    systemd.tmpfiles.rules = [
      "d ${dataBase} 0750 postgres postgres - -"
      "d ${pgBackups} 0750 postgres postgres - -"
    ];
    services.postgresql.dataDir = "${dataBase}";

    systemd.timers.postgresqlBackup-nextcloud.wantedBy = lib.mkForce [ ];
    systemd.timers.postgresqlBackup-onlyoffice.wantedBy = lib.mkForce [ ];
    services.postgresqlBackup = {
      enable = true;
      databases = [ "nextcloud" "onlyoffice" ];
      compression = "zstd";
      location = pgBackups;
    };

    services.borgbackup.jobs =
      let
        cfg = config.services.nextcloud;
      in
      {
        nextcloud = {
          paths = [ "${ncHome}" ];
          encryption.mode = "none";
          environment.BORG_RSH = "ssh -i ${config.sops.secrets."borgnextcloud".path}";
          repo = "${secrets.hosts.rpi3.user}@${secrets.hosts.rpi3.dns}:/external/nextcloud";
          compression = "auto,zstd";
          readWritePaths = [ config.services.nextcloud.datadir ];
          startAt = "Mon *-*-* 04:00:00";
          preHook = ''
            echo "Enabling maintenance mode..."
            ${cfg.occ}/bin/nextcloud-occ maintenance:mode --on
          '';
          postHook = ''
            echo "Disabling maintenance mode..."
            ${cfg.occ}/bin/nextcloud-occ maintenance:mode --off
          '';
        };
        nextcloud_database = {
          group = "nextcloud";
          user = "nextcloud";
          dumpCommand = pkgs.writeShellScript "builder.sh" ''
            ${config.services.postgresql.package}/bin/pg_dump nextcloud -U nextcloud --no-password
          '';
          encryption.mode = "none";
          environment.BORG_RSH = "ssh -i ${config.sops.secrets."borgnextcloud".path}";
          repo = "${secrets.hosts.rpi3.user}@${secrets.hosts.rpi3.dns}:/external/nextcloud_database";
          compression = "auto,zstd";
          readWritePaths = [ config.services.nextcloud.datadir ];
          startAt = "Mon *-*-* 06:00:00";
          preHook = ''
            echo "Enabling maintenance mode..."
            ${cfg.occ}/bin/nextcloud-occ maintenance:mode --on
          '';
          postHook = ''
            echo "Disabling maintenance mode..."
            ${cfg.occ}/bin/nextcloud-occ maintenance:mode --off
          '';
        };
      };

    programs.ssh.knownHosts = {
      ${secrets.hosts.rpi3.dns}.publicKey = secrets.hosts.rpi3.pubkey;
    };

    sops.secrets."borgnextcloud" = {
      sopsFile = "${private}/secrets/sops/backup_borg_nextcloud/id_ed25519";
      format = "binary";
      owner = "nextcloud";
      group = "nextcloud";
    };

    sops.secrets."nextcloud" = {
      sopsFile = "${private}/secrets/sops/nextcloud";
      format = "binary";
      owner = "nextcloud";
      group = "nextcloud";
    };
    environment.systemPackages = [ pkgs.ffmpeg-headless ];

    services.nextcloud = {
      enable = true;
      hostName = "cloud.${secrets.domain}";
      # Need to manually increment with every major upgrade.
      package = pkgs.nextcloud29;
      # Let NixOS install and configure the database automatically.
      database.createLocally = true;
      home = "${vars.serviceData}/nextcloud";
      # Let NixOS install and configure Redis caching automatically.
      configureRedis = true;
      # Increase the maximum file upload size to avoid problems uploading videos.
      maxUploadSize = "16G";
      https = true;
      extraAppsEnable = true;
      extraApps = with config.services.nextcloud.package.packages.apps; {
        # List of apps we want to install and are already packaged in
        # https://github.com/NixOS/nixpkgs/blob/master/pkgs/servers/nextcloud/packages/nextcloud-apps.json
        inherit calendar contacts mail notes tasks memories previewgenerator onlyoffice;
      };
      settings = {
        default_phone_region = "ES";
        # Allow access when hitting either of these hosts or IPs
        trusted_proxies = [ "127.0.0.1" ];
        maintenance_window_start = 4; # Run jobs at 4am UTC
        memories.exiftool = "${lib.getExe pkgs.exiftool}";
        memories.vod.ffmpeg = "${lib.getExe pkgs.ffmpeg-headless}";
        memories.vod.ffprobe = "${pkgs.ffmpeg-headless}/bin/ffprobe";
        preview_ffmpeg_path = "${pkgs.ffmpeg-headless}/bin/ffmpeg";
      };
      config = {
        adminpassFile = "${config.sops.secrets."nextcloud".path}";
        dbtype = "pgsql";
      };
      phpOptions = {
        "opcache.interned_strings_buffer" = "16";
        "output_buffering" = "0";
      };
    };
    systemd.services.nextcloud-cron = {
      path = [ pkgs.perl ];
    };

    services.nginx = {
      enable = lib.mkForce false;
    };

    systemd.services.phpfpm-nextcloud.serviceConfig = {
      DeviceAllow = [ "/dev/dri/renderD128" ];
      SupplementaryGroups = [ "render" "video" ];
      PrivateDevices = lib.mkForce false;
    };

    services.phpfpm.pools.nextcloud.settings = {
      "listen.owner" = config.services.caddy.user;
      "listen.group" = config.services.caddy.group;
    };
    users.users.caddy.extraGroups = [ "nextcloud" ];

    services.caddy =
      let
        cfg = config.services.nextcloud;
        fpm = config.services.phpfpm.pools.nextcloud;
      in
      {
        virtualHosts."https://${cfg.hostName}" = {
          extraConfig = ''
            encode zstd gzip
            root * ${config.services.nginx.virtualHosts.${cfg.hostName}.root}
            redir /.well-known/carddav /remote.php/dav/ 301
            redir /.well-known/caldav /remote.php/dav/ 301
            redir /.well-known/* /index.php{uri} 301
            redir /remote/* /remote.php{uri} 301
            header {
              Strict-Transport-Security max-age=31536000
              Permissions-Policy interest-cohort=()
              X-Content-Type-Options nosniff
              X-Frame-Options SAMEORIGIN
              Referrer-Policy no-referrer
              X-XSS-Protection "1; mode=block"
              X-Permitted-Cross-Domain-Policies none
              X-Robots-Tag "noindex, nofollow"
              -X-Powered-By
            }
            php_fastcgi unix/${fpm.socket} {
              root ${config.services.nginx.virtualHosts.${cfg.hostName}.root}
              env front_controller_active true
              env modHeadersAvailable true
            }
            @forbidden {
              path /build/* /tests/* /config/* /lib/* /3rdparty/* /templates/* /data/*
              path /.* /autotest* /occ* /issue* /indie* /db_* /console*
              not path /.well-known/*
            }
            error @forbidden 404
            @immutable {
              path *.css *.js *.mjs *.svg *.gif *.png *.jpg *.ico *.wasm *.tflite
              query v=*
            }
            header @immutable Cache-Control "max-age=15778463, immutable"
            @static {
              path *.css *.js *.mjs *.svg *.gif *.png *.jpg *.ico *.wasm *.tflite
              not query v=*
            }
            header @static Cache-Control "max-age=15778463"
            @woff2 path *.woff2
            header @woff2 Cache-Control "max-age=604800"
            file_server
          '';
        };
        virtualHosts."office.${secrets.domain}".extraConfig = ''
          reverse_proxy http://127.0.0.1:8000 {
            # Required to circumvent bug of Onlyoffice loading mixed non-https content
            header_up X-Forwarded-Proto https
          }
        '';
      };
    # Workaround because the nextcloud module requires nginx
    users.users.nginx = {
      group = "nginx";
      isSystemUser = true;
    };
    users.groups.nginx = { };

    services.onlyoffice = {
      enable = true;
      hostname = "office.${secrets.domain}";
      jwtSecretFile = "${config.sops.secrets."onlyoffice".path}";
    };

    sops.secrets."onlyoffice" = {
      sopsFile = "${private}/secrets/sops/onlyoffice";
      format = "binary";
      owner = "onlyoffice";
      group = "onlyoffice";
    };
  };
}
