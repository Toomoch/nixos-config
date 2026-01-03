{ wlib, lib }:

wlib.wrapModule (
  { config, wlib, ... }:
  {
    options = {
      configFile = lib.mkOption {
        type = wlib.types.file config.pkgs;
        description = ''
          kanshi configuration settings file.
          See kanshi(5)
        '';
        example.content = ''
          include /etc/kanshi/config.d/*
          profile {
          	output LVDS-1 disable
          	output "Some Company ASDF 4242" {
          		mode 1600x900
          		position 0,0
          	}
          }
          profile nomad {
          	output LVDS-1 enable scale 2
          }
        '';
      };
    };

    config.package = lib.mkDefault config.pkgs.kanshi;
    config.flags = {
      "--config" = builtins.toString config.configFile.path;
    };
  }
)
