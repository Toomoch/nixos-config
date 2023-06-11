{ config, pkgs, lib, ... }:
{
  #TODO
  #virtualisation.oci-containers = {
  #  backend = "podman";
  #  containers = {
  #    homeassistant = {
  #      autoStart = true;
  #      image = "homeassistant/home-assistant:stable";
  #      volumes = [
  #        "/home/arnau/hass_config:/config:Z"
  #      ];
  #      ports = [
  #        "8123:8123"
  #      ];
  #      extraOptions = [
  #        "--cap-add=CAP_NET_RAW"
  #        "--tz=local"
  #      ];
  #    };
  #  };
  #};
  #systemd.services.podman-homeassistant.serviceConfig.User = "arnau";
#
  systemd.services.podman-hass = {
    enable = true;
    wantedBy = [ "default.target" ]; 
    after = [ "network.target" ];
    description = "Home Assistant pod";
    serviceConfig = 
    let 
      podmancli = "${pkgs.bash}/bin/bash -l -c \"${config.virtualisation.podman.package}/bin/podman";
      endpodmancli = "\"";
      hass_version = "0.118.0";
      podname = "hass";
      cleanup_pod = [
        "${podmancli} stop -i ${podname} ${endpodmancli}"
        "${podmancli} rm -i ${podname} ${endpodmancli}"
      ];
    in
    {
      User = "arnau";
      WorkingDirectory = "/home/arnau";
      ExecStartPre = cleanup_pod;
      ExecStart = "${podmancli} run " +
        "--rm " +
        "--name=${podname} " +
        "--sdnotify=conmon " +
        "--log-driver=journald " +
        "-p '8123:8123' " +
        "-v '/etc/localtime:/etc/localtime:ro' " +
        "-v '/home/arnau/hass_config:/config:Z' " +
        "homeassistant/home-assistant:stable ${endpodmancli}"; 

      Type = "notify";
      NotifyAccess = "all";
      ExecStop = "${podmancli} stop ${podname} ${endpodmancli}";
      ExecStopPost = cleanup_pod;
      Restart = "always";
      TimeoutStopSec = 15;
    };
  };
}
