{ config, lib, ... }:
let
  hass_config = "${config.home.homeDirectory}/hass_config";
  homer_config = "${config.home.homeDirectory}/homer";
in
{
  home.activation.create_service_config = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ${hass_config}
  '';
  
  home.file."homer/" = {
    source = ./homer; 
    recursive = true; 
  };

  systemd.user.services.homeassistant = {
    Unit = {
      Description = "Podman container-homeassistant.service";
      Documentation = [ "man:podman-generate-systemd(1)" ];
      Wants = "network-online.target";
      After = "network-online.target";
      RequiresMountsFor = "%t/containers";
    };

    Service = {
      Environment = "PODMAN_SYSTEMD_UNIT=%n";
      Restart = "on-failure";
      TimeoutStopSec = 70;
      ExecStart = '' 
        /run/current-system/sw/bin/podman run \
        --cgroups=no-conmon \
        --rm \
        --sdnotify=conmon \
        --replace \
        -d \
        --name homeassistant \
        -v ${hass_config}:/config:Z \
        -p 8123:8123 \
        --cap-add=CAP_NET_RAW \
        --tz=local ghcr.io/home-assistant/home-assistant:stable
        '';
      ExecStop = ''
        /run/current-system/sw/bin/podman stop \
        --ignore -t 20 homeassistant
      '';
      ExecStopPost = ''
        /run/current-system/sw/bin/podman rm \
        -f \
        --ignore -t 20 homeassistant
      '';
      Type = "notify";
      NotifyAccess = "all";
      RestartForceExitStatus = 100;
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  systemd.user.services.homer = {
    Unit = {
      Description = "Podman container-homer.service";
      Documentation = [ "man:podman-generate-systemd(1)" ];
      Wants = "network-online.target";
      After = "network-online.target";
      RequiresMountsFor = "%t/containers";
    };

    Service = {
      Environment = "PODMAN_SYSTEMD_UNIT=%n";
      Restart = "on-failure";
      TimeoutStopSec = 70;
      ExecStart = '' 
        /run/current-system/sw/bin/podman run \
        --cgroups=no-conmon \
        --rm \
        --sdnotify=conmon \
        --replace \
        -d \
        --name homer \
        -v ${homer_config}:/www/assets:Z \
        -p 8080:8080 \
        --tz=local ghcr.io/b4bz/homer:stable
        '';
      ExecStop = ''
        /run/current-system/sw/bin/podman stop \
        --ignore -t 20 homer
      '';
      ExecStopPost = ''
        /run/current-system/sw/bin/podman rm \
        -f \
        --ignore -t 20 homer
      '';
      Type = "notify";
      NotifyAccess = "all";
      RestartForceExitStatus = 100;
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
