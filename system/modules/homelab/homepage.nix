{ config, inputs, pkgs-unstable, lib, pkgs, secrets, private, ... }:
let
  vars = import ./variables.nix { inherit config inputs pkgs lib; };
in
{
  options.homelab = {
    homepage-dashboard.enable = lib.mkEnableOption "Whether to enable homepage";
  };

  imports = [
    (import "${private}/modules/homepage.nix" {
      inherit secrets;
    })
  ];
  config = lib.mkMerge [
    (lib.mkIf vars.cfg.homepage-dashboard.enable {
      age.secrets.homepage.rekeyFile = "${private}/secrets/age/homepage.age";

      services.homepage-dashboard = {
        enable = true;
        openFirewall = true;
        environmentFile = "${config.age.secrets.homepage.path}";
        services = [
          {
            "Services" = [
              {
                "Nextcloud" = {
                  description = "Nextcloud Instance";
                  icon = "nextcloud"; # https://github.com/walkxcode/dashboard-icons
                  href = "https://cloud.${secrets.domain}";
                  widget = {
                    type = "nextcloud";
                    url = "https://cloud.${secrets.domain}";
                    key = "{{HOMEPAGE_VAR_NC_KEY}}";
                  };
                };
              }
              {
                "Home Assistant" = {
                  description = "Home Assistant Instance";
                  icon = "home-assistant";
                  href = "https://homeassistant.${secrets.domain}";
                  widget = {
                    type = "homeassistant";
                    url = "https://homeassistant.${secrets.domain}";
                    key = "{{HOMEPAGE_VAR_HASS_API}}";
                  };
                };
              }
              {
                "OpenVSCode Server" = {
                  icon = "vscode";
                  href = "https://code.${secrets.domain}";
                };
              }
              {
                "Cockpit" = {
                  icon = "cockpit";
                  href = "https://cockpit.${secrets.domain}";
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
