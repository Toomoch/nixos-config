{
  config,
  lib,
  pkgs,
  inputs,
  private,
  self,
  ...
}:
let
  cfg = config.custom.host;
in
{
  options.custom.host = {
    enable = lib.mkEnableOption "Whether to enable the module for host metadata";
    # host = lib. "IP or name for accessing this host";
    port = lib.mkOption {
      type = lib.types.int;

      default = builtins.elemAt config.services.openssh.ports 0;
      description = "External SSH port";

    };
    publicKey = lib.mkOption {
      type = lib.types.str;
      description = "Public SSH key of this host";
    };
  };

  config = lib.mkIf cfg.enable {

    # home-manager.users.arnau.config.
    # users.users.arnau.openssh.authorizedKeys =
    #   let
    #     enabledHosts = lib.filterAttrs (
    #       name: value:
    #       (value.config.custom.host.enable or false)
    #       && value.config.custom.host.authorized
    #       && name != config.networking.hostName
    #     ) self.nixosConfigurations;
    #   in
    #   lib.mapAttrsToList (name: value: value.config.custom.host.publicKey) enabledHosts;
    #
  };
}
