{ config, inputs, pkgs-unstable, lib, pkgs, ... }:
let
  vars = import ./variables.nix { inherit config inputs pkgs lib; };
in
{
  options.homelab = {
    homepage-dashboard.enable = lib.mkEnableOption "Whether to enable homepage";
  };

  imports = [
    (import "${inputs.private}/modules/homepage.nix" {
      inherit vars;
    })
  ];
  config = lib.mkMerge [
    (lib.mkIf vars.cfg.homepage-dashboard.enable {
      sops.secrets."homepage-dashboard".sopsFile = "${ inputs. private}/secrets/sops/homepage-dashboard.env";
      sops.secrets."homepage-dashboard".format = "dotenv";

      services. homepage-dashboard = {
        enable = true;
        openFirewall = true;
        environmentFile = "${config.sops.secrets."homepage-dashboard".path}";
        services = [
          {
            "Services" = [
              {
                "Immich" = {
                  description = "Immich";
                  icon = "immich"; # https://github.com/walkxcode/dashboard-icons
                  href = "https://immich.${vars.domain}";
                  widget = {
                    type = "immich";
                    url = "https://immich.${vars.domain}";
                    key = "{{HOMEPAGE_VAR_IMMICH_API}}";
                  };
                };
              }
              {
                "Home Assistant" = {
                  description = "Home Assistant Instance";
                  icon = "home-assistant";
                  href = "https://homeassistant.${vars.domain}";
                  widget = {
                    type = "homeassistant";
                    url = "https://homeassistant.${vars.domain}";
                    key = "{{HOMEPAGE_VAR_HASS_API}}";
                  };
                };
              }
              {
                "OpenVSCode Server" = {
                  icon = "vscode";
                  href = "https://code.${vars.domain}";
                };
              }
              {
                "NextCloud" = {
                  icon = "nextcloud";
                  href = "https://cloud.${vars.domain}";
                };
              }
              {
                "Cockpit" = {
                  icon = "cockpit";
                  href = "https://cockpit.${vars.domain}";
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
