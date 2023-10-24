{ config, lib, pkgs, ... }:
with lib; let
  cfg = config.desktop;
  discover-wrapped = pkgs.symlinkJoin
    {
      name = "discover-flatpak-backend";
      paths = [ pkgs.libsForQt5.discover ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/plasma-discover --add-flags "--backends flatpak"
      '';
    };
in
{
  options.desktop = {
    gnome.enable = mkEnableOption ("Whether to enable Gnome with GDM");
    kde.enable = mkEnableOption ("Whether to enable KDE with SDDM");
  };

  config = mkMerge [
    (mkIf cfg.gnome.enable {
      # Enable GNOME
      services.xserver.enable = true;
      services.xserver.displayManager.gdm.enable = true;
      services.xserver.desktopManager.gnome.enable = true;
    })
    (mkIf cfg.kde.enable {
      # Enable KDE Plasma
      services.xserver.enable = true;
      services.xserver.displayManager.sddm.enable = true;
      services.xserver.desktopManager.plasma5.enable = true;
      services.xserver.displayManager.defaultSession = "plasmawayland";
      programs.dconf.enable = true;

      environment.systemPackages = with pkgs; [
        discover-wrapped
      ];
    })
  ];
}
