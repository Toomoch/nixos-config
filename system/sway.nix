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

}
