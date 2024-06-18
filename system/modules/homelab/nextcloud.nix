{ inputs, pkgs, lib, config, ... }:
let
  vars = import ./variables.nix { inherit config inputs pkgs lib; };
in
{

  options.homelab = {
    nextcloud.enable = lib.mkEnableOption "Whether to enable Nextcloud";
  };

  config = {
    sops.secrets."nextcloud".sopsFile = "${inputs.private}/secrets/sops/nextcloud";
    sops.secrets."nextcloud".format = "binary";
    sops.secrets."nextcloud".owner = "nextcloud";
    sops.secrets."nextcloud".group = "nextcloud";
    services.nextcloud = {
      enable = true;
      hostName = "cloud.${vars.domain}";

      # Need to manually increment with every major upgrade.
      package = pkgs.nextcloud29;

      # Let NixOS install and configure the database automatically.
      database.createLocally = true;

      # Let NixOS install and configure Redis caching automatically.
      configureRedis = true;

      # Increase the maximum file upload size to avoid problems uploading videos.
      maxUploadSize = "16G";
      https = true;

      autoUpdateApps.enable = true;
      extraAppsEnable = true;
      extraApps = with config.services.nextcloud.package.packages.apps; {
        # List of apps we want to install and are already packaged in
        # https://github.com/NixOS/nixpkgs/blob/master/pkgs/servers/nextcloud/packages/nextcloud-apps.json
        inherit calendar contacts mail notes tasks;
      };


      config = {
        overwriteProtocol = "https";
        defaultPhoneRegion = "ES";
        dbtype = "pgsql";
        adminuser = "admin";
        adminpassFile = "${config.sops.secrets."nextcloud".path}";
      };
    };

    services.nginx = {
      enable = lib.mkForce false;
    };

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
            redir /.well-known/carddav /remote.php/dav 301
            redir /.well-known/caldav /remote.php/dav 301
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
      };
  };
}
