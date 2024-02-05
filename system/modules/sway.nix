{ config, lib, pkgs, ... }:
with lib; let
  cfg = config.desktop;

  greetdSwayConfig = pkgs.writeText "greetd-sway-config" ''
    xwayland disable
    input "type:touchpad" {
      tap enabled
    }
    exec "${config.programs.regreet.package}/bin/regreet; swaymsg exit"
    include /etc/sway/config.d/*
  '';
in
{
  options.desktop = {
    sway.enable = mkEnableOption ("Whether to enable Sway with GTKgreet");
    hyprland.enable = mkEnableOption ("Whether to enable Hyprland");
    regreet.enable = mkEnableOption ("Whether to enable regreet");
  };

  config = mkMerge [
    (mkIf cfg.regreet.enable {
      xdg.portal = {
        enable = cfg.sway.enable;
        # gtk portal needed to make gtk apps happy
        extraPortals = with pkgs; [ xdg-desktop-portal-gtk ] ++ optional cfg.sway.enable xdg-desktop-portal-gtk;
      };

      programs.hyprland.enable = cfg.hyprland.enable;

      # Sway
      programs.sway.enable = cfg.sway.enable;
      programs.sway.wrapperFeatures.gtk = cfg.sway.enable;
      programs.sway.extraOptions = [
        "--unsupported-gpu"
      ];

      programs.dconf.enable = true;
      environment.systemPackages = with pkgs; [
        wayland
        xorg.xwininfo
        sway
        adw-gtk3
        gnome.adwaita-icon-theme
      ];

      # Gnome Keyring
      services.gnome.gnome-keyring.enable = true;

      # Enable wayland in electron apps
      #environment.sessionVariables.NIXOS_OZONE_WL = "1"; Disabled because of https://github.com/microsoft/vscode/issues/184124
      # Enable wayland in firefox
      environment.sessionVariables.MOZ_ENABLE_WAYLAND = "1";
      # Fix Java apps in WMs
      environment.sessionVariables._JAVA_AWT_WM_NONREPARENTING = "1";

      # For Gnome Disks
      services.udisks2.enable = true;

      # For auto mounting in Nautilus and Thunar
      services.gvfs.enable = true;
      services.dbus.enable = true;

      # Don’t shutdown when power button is short-pressed
      services.logind.extraConfig = ''
        HandlePowerKey=ignore
      '';

      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            command = "sway --unsupported-gpu --config ${greetdSwayConfig}";
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
    })
  ];
}
