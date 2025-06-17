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
    home.packages = [ pkgs.xwayland-satellite ];
    services.kanshi.systemdTarget = lib.mkForce "graphical-session.target";
    xdg.configFile."niri/config.kdl".source = ./niri.kdl;

  };

}
