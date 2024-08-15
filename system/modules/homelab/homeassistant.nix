{ inputs, pkgs, lib, config, ... }:
let
  hass_config = "${vars.serviceData}/hass";
  vars = import ./variables.nix { inherit config inputs pkgs lib; };
in
{

  options.homelab = {
    homeassistant.enable = lib.mkEnableOption "Whether to enable homelab stuff";
  };

  config = lib.mkMerge [
    (lib.mkIf vars.cfg.homeassistant.enable {
      virtualisation.oci-containers.containers.homeassistant = {
        image = "ghcr.io/home-assistant/home-assistant:stable";
        ports = [
          "8123:8123"
        ];
        volumes = [
          "${hass_config}:/config:Z"
          "${./homeassistant-configuration.yaml}:/config/configuration.yaml:ro"
        ];
        environment = {
          TZ = vars.timezone;
        };
        extraOptions = vars.commonextraOptions ++ [
          "--network=host"
          "--device=/dev/serial/by-id/usb-1a86_USB_Serial-if00-port0:/dev/ttyUSB0:rw"
        ];

      };
    })
  ];
}
