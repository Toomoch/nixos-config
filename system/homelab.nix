{ ... }:
{
  services.cockpit.enable = true;
  services.cockpit.openFirewall = true;

  systemd.tmpfiles.rules = [
    "d /var/lib/jmusicbot 0755 root root"
  ];
  services.jmusicbot.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 8123 ]; #HomeAssistant
}
