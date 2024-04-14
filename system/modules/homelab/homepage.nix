{ config, inputs, pkgs-unstable, lib, pkgs, ... }:
with lib; with import ./variables.nix { inherit config inputs pkgs lib; };
let

in
{
  options.homelab = {
    homepage-dashboard.enable = mkEnableOption ("Whether to enable homepage");
  };

  config = mkMerge [
    (mkIf cfg.homepage-dashboard.enable {
      sops.secrets."homepage-dashboard".sopsFile = "${inputs.private}/secrets/sops/homepage-dashboard.env";
      sops.secrets."homepage-dashboard".format = "dotenv";

      services.homepage-dashboard = {
        enable = true;
        openFirewall = true;
        environmentFile = "${config.sops.secrets."homepage-dashboard".path}";
        services = [
          {
            "Services" = [
              {
                "Immich" = {
                  description = "Immich";
                  icon = "immich";
                  href = "https://immich.${domain}";
                  widget = {
                    type = "immich";
                    url = "https://immich.${domain}";
                    key = "{{HOMEPAGE_VAR_IMMICH_API}}";
                  };
                };
              }
              {
                "Home Assistant" = {
                  description = "Home Assistant Instance";
                  icon = "home-assistant";
                  href = "https://homeassistant.${domain}";
                  widget = {
                    type = "homeassistant";
                    url = "https://homeassistant.${domain}";
                    key = "{{HOMEPAGE_VAR_HASS_API}}";
                  };
                };
              }
            ];
          }
        ];
        widgets = [
          {
            resources = {
              label = "System";
              cpu = true;
              cputemp = true;
              uptime = true;
              memory = true;
            };
          }
          {
            resources = {
              label = "ZFS data";
              expanded = true;
              disk = [ "/zstorage/data" ];
            };
          }
          {
            resources = {
              label = "ZFS share";
              expanded = true;
              disk = [ "/zstorage/share" ];
            };
          }
          {
            resources = {
              label = "BTRFS root";
              expanded = true;
              disk = [ "/" ];
            };
          }
        ];
      };
    })
  ];
}
