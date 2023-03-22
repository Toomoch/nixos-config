{ config, pkgs, lib, ... }:
{
  #xdg-portal
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    # gtk portal needed to make gtk apps happy
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  #Sway
  programs.sway.enable = true;
  programs.sway.wrapperFeatures.gtk = true;
  programs.dconf.enable = true;

  environment.systemPackages = with pkgs; [
    wayland
    xorg.xwininfo
  ];
  
  #Gnome Keyring
  services.gnome.gnome-keyring.enable = true;

  # Enable wayland in electron apps
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  # Enable wayland in firefox
  environment.sessionVariables.MOZ_ENABLE_WAYLAND = "1";

  # For Gnome Disks
  services.udisks2.enable = true;

  # For auto mounting in Nautilus and Thunar
  services.gvfs.enable = true;
  services.dbus.enable = true;

}
