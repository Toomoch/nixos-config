{ inputs, pkgs, lib, config, secrets, ... }:
let
  vars = import ./variables.nix { inherit config inputs pkgs lib; };
  immichRoot = "${vars.serviceData}/immich";
  cfg = config.custom.immich;
  hostname = "immich.${secrets.domain}";
in {
  options.custom.immich.enable =
    lib.mkEnableOption "Whether to enable immich stuff";

  config = lib.mkIf cfg.enable {
    services.immich = {
      enable = true;
      mediaLocation = immichRoot;
    };

    systemd.tmpfiles.rules = [
      "d ${immichRoot} 0750 ${config.services.immich.user} ${config.services.immich.group} - -"
    ];

    systemd.services.immich-server.serviceConfig = {
      DeviceAllow = [ "/dev/dri/renderD128" ];
      SupplementaryGroups = [ "render" "video" ];
      PrivateDevices = lib.mkForce false;
    };
    users.users.${config.services.immich.user}.extraGroups =
      [ "video" "render" ];

    services.caddy.virtualHosts."https://${hostname}" = {
      extraConfig = ''
        reverse_proxy http://${config.services.immich.host}:${builtins.toString config.services.immich.port} {
        }
      '';
    };
  };
}
