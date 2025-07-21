{
  config,
  lib,
  pkgs,
  flake-root,
  ...
}:
let
  cfg = config.custom.desktop;
  custom-session = import ./functions/custom-session.nix;
  river-custom = custom-session {
    inherit pkgs lib;
    name = "river";
    exec = "${lib.getExe pkgs.river}";
  };
in
{
  options.custom.desktop = {
    sway.enable = lib.mkEnableOption "Whether to enable Sway with GTKgreet";
    river.enable = lib.mkEnableOption "Whether to enable riverwm";
    niri.enable = lib.mkEnableOption "Whether to enable niri";
    hyprland.enable = lib.mkEnableOption "Whether to enable Hyprland";
    regreet.enable = lib.mkEnableOption "Whether to enable regreet";
    tuigreet.enable = lib.mkEnableOption "Whether to enable tuigreet";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.sway.enable {
      xdg.portal = {
        enable = cfg.sway.enable;
        # gtk portal needed to make gtk apps happy
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
          xdg-desktop-portal-wlr
        ];
      };

      programs.hyprland.enable = cfg.hyprland.enable;
      programs.river.enable = cfg.river.enable;
      services.displayManager.sessionPackages = [ ] ++ lib.optional cfg.river.enable river-custom;
      programs.niri.enable = cfg.niri.enable;
      systemd.user.targets.xdg-desktop-autostart.enable = false;


      # Sway
      programs.sway.enable = true;
      programs.sway.wrapperFeatures.gtk = true;
      programs.sway.extraOptions = [ "--unsupported-gpu" ];

      programs.dconf.enable = true;
      environment.systemPackages = with pkgs; [
        wayland
        xorg.xwininfo
        sway
        adw-gtk3
        adwaita-icon-theme
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
      environment.sessionVariables.NIXOS_OZONE_WL = "1"; # Disabled because of https://github.com/microsoft/vscode/issues/184124
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
      security.pam.services.hyprlock = { };
      security.pam.services.waylock = { };
    })
    # buggy https://github.com/rharish101/ReGreet/issues/45
    (lib.mkIf cfg.regreet.enable {
      programs.regreet = {
        enable = true;
        cageArgs = [
          "-s"
          "-m"
          "last"
        ];
        font = {
          package = pkgs.rubik;
          name = "Rubik";
          size = 12;
        };
        settings = {
          background = {
            fit = "Cover";
            path = /${flake-root}/assets/lockscreen.png;

          };
          GTK = {
            application_prefer_dark_theme = true;
          };
        };
      };
    })
    (lib.mkIf cfg.tuigreet.enable {
      # Stolen from https://github.com/sjcobb2022/nixos-config/blob/aa74d65ebb9ec49316b1f3a693176ae37381712e/hosts/common/optional/greetd.nix
      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --remember-session";
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
    })
  ];
}
