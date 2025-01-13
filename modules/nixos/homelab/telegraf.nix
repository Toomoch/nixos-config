{ inputs, pkgs, lib, config, secrets, ... }:
let cfg = config.custom.telegraf;

in {
  options.custom.telegraf = {
    enable = lib.mkEnableOption "Whether to enable homelab stuff";
    influxdbHost = lib.mkOption {
      type = lib.types.str;
      default = secrets.hosts.h81.dns;
      description = "DB to push metrics to";
    };
    influxdbPort = lib.mkOption {
      type = lib.types.int;
      default = 8428;
      description = "victoriametrics port";
    };
  };

  # manually add the passwords with smbpasswd -a my_user

  config = lib.mkIf cfg.enable {
    services.telegraf = {
      enable = true;
      extraConfig = {
        inputs = {
          cpu = {
            percpu = true;
            totalcpu = true;
            report_active = true;
            collect_cpu_time = true;
          };
          mem = { };
          processes = { };
          system = { };
          disk = { };
        };
        outputs = {
          influxdb = {
            database = "victoriametrics";
            urls =
              [ "http://${cfg.influxdbHost}:${toString cfg.influxdbPort}" ];
          };
        };
      };
    };
  };
}
