{ config, pkgs, ... }:
{

    virtualisation.oci-containers.containers.homeassistant = {
      image = "ghcr.io/home-assistant/home-assistant:stable";
      ports = [ "8123:8123" ];
      volumes = [
        "${config.custom.homelab.serviceDataDir}/hass:/config:Z"
        "${./homeassistant-configuration.yaml}:/config/configuration.yaml:ro"
      ];
      environment = { TZ = "Europe/Madrid"; };
      extraOptions = [

        "--pull=always"
        "--network=host"
        #"--device=/dev/serial/by-id/usb-1a86_USB_Serial-if00-port0:/dev/ttyUSB0:rw"
      ];

    };
    users.users.hass = {
      extraGroups = [
        "dialout" # Allow access to serial device (for Arduino dev)
      ];
    };

    services.caddy.virtualHosts."homeassistant.${config.custom.homelab.primaryDomain}" =
      {
        extraConfig = ''
          reverse_proxy localhost:8123
        '';
      };

    systemd.services.home-assistant = {
      serviceConfig.DeviceAllow =
        "/dev/serial/by-id/usb-1a86_USB_Serial-if00-port0 rw";
    };

    services.home-assistant = {
      enable = true;
      openFirewall = true;
      customComponents = [ pkgs.huawei_solar pkgs.som-energia-hass ];
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
        "melcloud"
        "lg_netcast"
      ];
      config = {
        http.server_port = 8124;
        # Includes dependencies for a basic setup
        # https://www.home-assistant.io/integrations/default_config/
        default_config = { };
      };
    };
}
