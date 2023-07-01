{ ... }:
{
  services.cockpit.enable = true;
  services.cockpit.openFirewall = true;

  systemd.tmpfiles.rules = [
    "d /var/lib/jmusicbot 0755 root root"
    "d /etc/nginx/data 0755 root root"
    "d /etc/nginx/letsencrypt 0755 root root"
  ];
  services.jmusicbot.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 8123 8080 9090]; #HomeAssistant

  virtualisation.oci-containers.backend = "docker";
  virtualisation.oci-containers.containers.nginx = {
    image = "docker.io/jc21/nginx-proxy-manager:latest";
    ports = [
      "80:80"
      "443:443"
      "81:81"
    ];
    volumes = [
      "/etc/nginx/data:/data"
      "/etc/nginx/letsencrypt:/etc/letsencrypt"
    ];
  };

}