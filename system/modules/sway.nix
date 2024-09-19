{ config, lib, pkgs, ... }:
let
  cfg = config.desktop;
in
{
  options.desktop = {
    sway.enable = lib.mkEnableOption "Whether to enable Sway with GTKgreet";
    hyprland.enable = lib.mkEnableOption "Whether to enable Hyprland";
    regreet.enable = lib.mkEnableOption "Whether to enable regreet";
    tuigreet.enable = lib.mkEnableOption "Whether to enable tuigreet";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.sway.enable
      {
        xdg.portal = {
          enable = cfg.sway.enable;
          # gtk portal needed to make gtk apps happy
          extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
        };

        programs.hyprland.enable = cfg.hyprland.enable;

        # Sway
        programs.sway.enable = true;
        programs.sway.wrapperFeatures.gtk = true;
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
          waypipe
        ];

        # Gnome Keyring
        services.gnome.gnome-keyring.enable = true;
        security.pam.services.greetd.enableGnomeKeyring = true;
        programs.thunar = {
          enable = true;
          plugins = with pkgs.xfce; [
            thunar-archive-plugin
            thunar-volman
            thunar-media-tags-plugin
          ];
        };
        programs.file-roller.enable = true;
        # Enable wayland in electron apps
        environment.sessionVariables.NIXOS_OZONE_WL = "1"; #Disabled because of https://github.com/microsoft/vscode/issues/184124
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
        services.blueman.enable = true;

        security.pam.services.gtklock = { };
      })
    (lib.mkIf
      cfg.regreet.enable
      {
        programs.regreet = {
          enable = true;
          cageArgs = [ "-s" "-m" "last" ];
          settings = {
            background = {
              fit = "Cover";
              path = ../assets/lockscreen.png;
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
      })
    (lib.mkIf
      cfg.tuigreet.enable
      {
        # Stolen from https://github.com/sjcobb2022/nixos-config/blob/aa74d65ebb9ec49316b1f3a693176ae37381712e/hosts/common/optional/greetd.nix
        services.greetd = {
          enable = true;
          settings = {
            default_session = {
              command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd sway";
              user = "greeter";
            };
          };
        };

        systemd.services.greetd.serviceConfig = {
          Type = "idle";
          StandardInput = "tty";
          StandardOutput = "tty";
          StandardError = "journal"; # Without this errors will spam on screen
          # Without these bootlogs will spam on screen
          TTYReset = true;
          TTYVHangup = true;
          TTYVTDisallocate = true;
        };
      }
    )
  ];
}
