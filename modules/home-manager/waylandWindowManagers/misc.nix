{
  config,
  flake-root,
  pkgs,
  lib,
  ...
}:
{

  options.custom.wl = {
    enable = lib.mkEnableOption "Whether to enable wl stuff";
  };
  config = lib.mkIf config.custom.wl.enable {
    home.packages = with pkgs; [
      swayosd
    ];

    services.swaync.enable = true;

    services.blueman-applet.enable = true;
    services.wpaperd = {
      enable = false;
      settings.default = {
        path = "${config.xdg.userDirs.pictures}/wallpapers";
        duration = "5m";
      };
    };

  };

}
