{
  pkgs,
  lib,
  config,
  ...
}:
{

  options.custom.wl.niri = {
    enable = lib.mkEnableOption "Whether to enable niri stuff";
  };
  config = lib.mkIf config.custom.wl.niri.enable {
    services.kanshi.systemdTarget = lib.mkForce "graphical-session.target";

  };

}
