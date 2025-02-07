{ config, lib, pkgs, ... }:
let
  cfg = config.custom.desktop;
in
{
  options.custom.desktop = {
    gnome.enable = lib.mkEnableOption "Whether to enable Gnome with GDM";
    kde.enable = lib.mkEnableOption "Whether to enable KDE with SDDM";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.gnome.enable {
      # Enable GNOME
      services.xserver.enable = true;
      services.xserver.displayManager.gdm.enable = true;
      services.xserver.desktopManager.gnome.enable = true;

      # Enable plymouth bootanimation
      boot.plymouth.enable = true;
    })
    (lib.mkIf cfg.kde.enable {
      # Enable KDE Plasma
      services.xserver.enable = true;
      services.displayManager.sddm.enable = true;
      services.desktopManager.plasma6.enable = true;
      services.displayManager.defaultSession = "plasma";
      programs.dconf.enable = true;

      environment.systemPackages = [
        pkgs.kdePackages.discover
      ];

      # Enable plymouth bootanimation
      boot.plymouth.enable = true;
    })
  ];
}
