{ config, ... }:
let
  silverbulletDir = "${config.custom.homelab.serviceDataDir}/silverbullet";
in
{
  virtualisation.oci-containers.containers.silverbullet = {
    image = "ghcr.io/silverbulletmd/silverbullet:0.10.4";
    volumes = [
      "${silverbulletDir}:/space"
    ];
    ports = [
      "3232:3000"
    ];
  };
  systemd.tmpfiles.rules = [ "d ${silverbulletDir} 0750 root root -" ];
  services.caddy.virtualHosts."silverbullet.${config.custom.homelab.primaryDomain}" = {
    extraConfig = ''
      reverse_proxy localhost:3232
    '';
  };
}
