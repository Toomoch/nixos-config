{ pkgs-unstable, ... }:
let
  nginx-data = "/var/lib/nginx/data";
  nginx-letsencrypt = "/var/lib/nginx/letsencrypt";
  jmusicbot = "/var/lib/jmusicbot";
in
{
  services.cockpit = {
    enable = true;
    openFirewall = true;
  };

  systemd.tmpfiles.rules = [
    "d ${jmusicbot} 0755 root root"
    "d ${nginx-data} 0755 root root"
    "d ${nginx-letsencrypt} 0755 root root"
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
    81 #nginx-proxy-manager
  ];

  virtualisation.oci-containers.backend = "docker";
  virtualisation.oci-containers.containers.nginx = {
    image = "docker.io/jc21/nginx-proxy-manager:latest";
    ports = [
      "80:80"
      "443:443"
      "81:81"
    ];
    volumes = [
      "${nginx-data}:/data"
      "${nginx-letsencrypt}:/etc/letsencrypt"
    ];
  };
  systemd.services."docker-nginx" = {
    serviceConfig = {
      DynamicUser = true;
      SupplementaryGroups = "docker";
      RestrictSUIDSGID = true;
      ProtectHome = true;
      PrivateDevices = true;
    };
  };

}
