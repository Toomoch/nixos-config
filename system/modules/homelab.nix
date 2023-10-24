{ inputs, config, lib, pkgs, pkgs-unstable, ... }:
with lib; let
  cfg = config.homelab;
  jmusicbot = "/var/lib/jmusicbot";
  dashy_config = "${inputs.private}/configfiles/dashy.yml";
  hass_config = "/var/lib/hass";
in
{
  options.homelab = {
    enable = mkEnableOption ("Whether to enable homelab stuff");
  };

  config = mkMerge [
    (mkIf cfg.enable {
      services.cockpit = {
        enable = true;
        openFirewall = true;
      };

      systemd.tmpfiles.rules = [
        "d ${jmusicbot} 0755 root root"
      ];
      services.jmusicbot.enable = true;

      services.code-server.enable = true;
      services.code-server.user = "arnau";
      services.code-server.package = pkgs-unstable.code-server;
      services.code-server.host = "0.0.0.0";
      services.code-server.auth = "none";
      systemd.services."code-server" = {
        serviceConfig = {
          PrivateDevices = true;
        };
      };

      networking.firewall.allowedTCPPorts = [
        8123 #HomeAssistant
        8080 #dashy
        9090 #cockpit
        4444 #code-server
        80 #caddy
        443 #caddy
      ];

      #Caddy reverse proxy
      services.caddy = {
        enable = true;
        package = pkgs.callPackage ../packages/caddy-plugins.nix { };
        extraConfig = builtins.readFile ("${inputs.private}/configfiles/Caddyfile");
      };

      sops.secrets."duckdns/token".sopsFile = "${inputs.private}/secrets/duckdns.env";
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
          extraOptions = [
            "--network=host"
            "--device=/dev/serial/by-id/usb-1a86_USB_Serial-if00-port0:/dev/ttyUSB0:rw"
          ];

        };
      };


      systemd.services."docker-dashy" = {
        serviceConfig = {
          DynamicUser = true;
          SupplementaryGroups = "docker";
          RestrictSUIDSGID = true;
          ProtectHome = true;
          PrivateDevices = true;
        };
      };
    })


  ];
}
