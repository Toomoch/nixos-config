{ ... }:
{

  # Disable stub resolver to not conflict with coredns
  services.resolved.extraConfig = ''
    DNSStubListener=no
  '';

  services.coredns = {
    enable = true;
  };
  networking.firewall.allowedUDPPorts = [ 53 ];
}
