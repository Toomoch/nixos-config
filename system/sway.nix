{ config, pkgs, lib, ... }:
let
  swayConfig = pkgs.writeText "greetd-sway-config" ''
    xwayland disable
    input "type:touchpad" {
      tap enabled
    }
    exec "${config.programs.regreet.package}/bin/regreet; swaymsg exit"
    include /etc/sway/config.d/*
  '';
in
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

  programs.hyprland.enable= true;

  environment.systemPackages = with pkgs; [
    wayland
    xorg.xwininfo
    adw-gtk3
    gnome.adwaita-icon-theme
  ];

  #Gnome Keyring
  services.gnome.gnome-keyring.enable = true;

  # Enable wayland in electron apps
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  # Enable wayland in firefox
  environment.sessionVariables.MOZ_ENABLE_WAYLAND = "1";
  # Fix Java apps in WMs
  environment.sessionVariables._JAVA_AWT_WM_NONREPARENTING = "1";

  # For Gnome Disks
  services.udisks2.enable = true;

  # For auto mounting in Nautilus and Thunar
  services.gvfs.enable = true;
  services.dbus.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.sway}/bin/sway --config ${swayConfig}";
      };
    };
  };

  programs.regreet = {
    enable = true;
    settings = {
      background = {
        fit = "Cover";
      };
      GTK = {
        cursor_theme_name = "Adwaita";
        font_name = "Rubik 12";
        icon_theme_name = "Adwaita";
        theme_name = "adw-gtk3-dark";
        application_prefer_dark_theme = true;
      };
    };
  };


  services.blueman.enable = true;

  security.pam.services.gtklock = { };
}



