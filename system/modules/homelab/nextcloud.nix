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
    services.postgresql = {
      dataDir = "${dataBase}";
      identMap = ''
        # ArbitraryMapName systemUser DBUser
        superuser_map      root      postgres
        superuser_map      postgres  postgres
        nextcloud_map      root      nextcloud
        nextcloud_map      nextcloud  nextcloud
      '';
      authentication = ''
        #type database  DBuser  auth-method optional_ident_map
        local all  postgres     peer        map=superuser_map
        local all  nextcloud    peer        map=nextcloud_map
      '';
    };

    systemd.services.borgmatic = {
      path = [ config.services.postgresql.package ];
      serviceConfig.CapabilityBoundingSet = "CAP_SETUID CAP_SETGID";
    };

    services.borgmatic = {
      enable = true;
      configurations.nextcloud = {
        archive_name_format = "nextcloud-{hostname}-{now}";
        source_directories = [ "${ncHome}" ];
        repositories = [
          {
            path = "/zstorage/backup";
            label = "local";
          }
        ];
        postgresql_databases = [
          {
            name = "nextcloud";
            format = "custom";
            username = "postgres";
          }
          {
            name = "onlyoffice";
            format = "custom";
            username = "postgres";
          }
        ];
        before_backup = [
          ''echo "Enabling maintenance mode..."''
          "${config.services.nextcloud.occ}/bin/nextcloud-occ maintenance:mode --on"
        ];
        after_backup = [
          ''echo "Disabling maintenance mode..."''
          "${config.services.nextcloud.occ}/bin/nextcloud-occ maintenance:mode --off"
        ];
        ssh_command = "${pkgs.openssh}/bin/ssh -i ${config.age.secrets.borgnextcloud.path}";
        keep_daily = 7;
        keep_weekly = 4;
      };
    };

    programs.ssh.knownHosts = {
      ${secrets.hosts.rpi3.dns}.publicKey = secrets.hosts.rpi3.pubkey;
    };

    age.secrets.borgnextcloud = {
      rekeyFile = "${private}/secrets/age/borgnextcloud.age";
      owner = "nextcloud";
      group = "nextcloud";
    };

    age.secrets.nextcloud = {
      rekeyFile = "${private}/secrets/age/nextcloud.age";
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
        adminpassFile = "${config.age.secrets.nextcloud.path}";
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
      jwtSecretFile = "${config.age.secrets.onlyoffice.path}";
    };

    age.secrets.onlyoffice = {
      rekeyFile = "${private}/secrets/age/onlyoffice.age";
      owner = "onlyoffice";
      group = "onlyoffice";
    };
  };
}
