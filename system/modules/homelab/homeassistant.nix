{ inputs, pkgs, lib, config, ... }:
with import ./variables.nix { inherit config inputs pkgs lib; };
with lib;
let
  hass_config = "${serviceData}/hass";
in
{

  options.homelab = {
    homeassistant.enable = mkEnableOption ("Whether to enable homelab stuff");
  };

  config = mkMerge [
    (mkIf cfg.homeassistant.enable {
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
          TZ = timezone;
        };
        extraOptions = commonextraOptions ++ [
          "--network=host"
          "--device=/dev/serial/by-id/usb-1a86_USB_Serial-if00-port0:/dev/ttyUSB0:rw"
        ];

      };
    })
  ];
}
