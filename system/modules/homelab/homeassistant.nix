{ inputs, pkgs, lib, config, pkgs-unstable, ... }:
let
  hass_config = "${vars.serviceData}/hass";
  vars = import ./variables.nix { inherit config inputs pkgs lib; };

  #huawei-solar = pkgs.callPackage ../../packages/huawei-solar.nix {
  #  python3 = pkgs.python312;

  #};
  #huawei_solar = pkgs.callPackage ../../packages/huawei_solar.nix {
  #  inherit huawei-solar;
  #};
in {

  options.homelab = {
    homeassistant.enable = lib.mkEnableOption "Whether to enable homelab stuff";
  };

  config = lib.mkMerge [
    (lib.mkIf vars.cfg.homeassistant.enable {
      virtualisation.oci-containers.containers.homeassistant = {
        image = "ghcr.io/home-assistant/home-assistant:stable";
        ports = [ "8123:8123" ];
        volumes = [
          "${hass_config}:/config:Z"
          "${./homeassistant-configuration.yaml}:/config/configuration.yaml:ro"
        ];
        environment = { TZ = vars.timezone; };
        extraOptions = vars.commonextraOptions ++ [
          "--network=host"
          "--device=/dev/serial/by-id/usb-1a86_USB_Serial-if00-port0:/dev/ttyUSB0:rw"
        ];

      };
      users.users.hass = {
        extraGroups = [
          "dialout" # Allow access to serial device (for Arduino dev)
        ];
      };

      systemd.services.home-assistant = {
        serviceConfig.DeviceAllow = "/dev/ttyUSB1 rw";
      };

      services.home-assistant = {
        enable = true;
        openFirewall = true;
#        customComponents = with pkgs.home-assistant-custom-components; [
#  huawei_solar
#]; 
        extraComponents = [
          # Components required to complete the onboarding
          "analytics"
          "google_translate"
          "met"
          "radio_browser"
          "shopping_list"
          # Recommended for fast zlib compression
          # https://www.home-assistant.io/integrations/isal
          "isal"
        ];
        config = {
          http.server_port = 8124;
          # Includes dependencies for a basic setup
          # https://www.home-assistant.io/integrations/default_config/
          default_config = { };
        };
      };
    })
  ];
}
