{ inputs, pkgs, lib, config, secrets, ... }:
let cfg = config.custom.prometheus;

in {
  options.custom.prometheus = {
    enable = lib.mkEnableOption "Whether to enable prometheus Nix SD";
    exporters = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
      options = {
        hostname = lib.mkOption {
          type = lib.types.str;
          description = "the hostname used to query this exporter";
          example = "example.com";
          default = lib.removeSuffix "/64" (builtins.elemAt config.systemd.network.networks."50-metrics".address 0);
        };
        port = lib.mkOption {
          type = lib.types.port;
          description = "The port number";
          example = 8080;
        };
        job = lib.mkOption {
          type = lib.types.str;
          description = "the job name";
          example = "node";
        };
      };
    });
      default = [];
      description = "Custom prometheus metadata for Nix SD";
    };
  };

  # manually add the passwords with smbpasswd -a my_user


}
