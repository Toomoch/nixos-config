{
  config,
  lib,
  pkgs,
  flake-root,
  inputs,
  ...
}:
let
  cfg = config.custom.desktop;
in
{
  options.custom.desktop = {
    sway.enable = lib.mkEnableOption "Whether to enable Sway and common desktop services";
    niri.enable = lib.mkEnableOption "Whether to enable niri";
    hyprland.enable = lib.mkEnableOption "Whether to enable Hyprland";

    greeter = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "regreet"
          "tuigreet"
          "cosmic"
        ]
      );
      default = null;
      description = "Which greeter to enable.";
    };
  };
  disabledModules = [
    "services/display-managers/cosmic-greeter.nix"
  ];
  imports = [
    "${inputs.nixpkgs}/nixos/modules/services/display-managers/cosmic-greeter.nix"
  ];

  config = {
    xdg.portal = lib.optionalAttrs cfg.sway.enable {
      enable = cfg.sway.enable;
      # gtk portal needed to make gtk apps happy
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
      ];
    };

    programs.hyprland.enable = cfg.sway.enable && cfg.hyprland.enable;
    programs.niri.enable = cfg.sway.enable && cfg.niri.enable;
    # niri attaches to xdg-desktop-autostart.target and this masks it
    systemd.user.targets.xdg-desktop-autostart.enable = cfg.sway.enable || cfg.niri.enable;

    # Sway
    programs.sway = {
      enable = cfg.sway.enable;
      wrapperFeatures.gtk = true;
      extraOptions = [ "--unsupported-gpu" ];
    };

    programs.dconf.enable = cfg.sway.enable;
    environment.systemPackages = lib.optionals cfg.sway.enable (
      with pkgs;
      [
        wayland
        xorg.xwininfo
        sway
        adw-gtk3
        adwaita-icon-theme
        waypipe
      ]
    );

    # Gnome Keyring
    services.gnome.gnome-keyring.enable = cfg.sway.enable;
    security.pam.services.greetd.enableGnomeKeyring = cfg.sway.enable;
    programs.thunar = {
      enable = cfg.sway.enable;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
        thunar-media-tags-plugin
      ];
    };
    programs.file-roller.enable = cfg.sway.enable;
    # Enable wayland in electron apps
    environment.sessionVariables.NIXOS_OZONE_WL = lib.mkIf cfg.sway.enable "1"; # Disabled because of https://github.com/microsoft/vscode/issues/184124
    # Enable wayland in firefox
    environment.sessionVariables.MOZ_ENABLE_WAYLAND = lib.mkIf cfg.sway.enable "1";
    # Fix Java apps in WMs
    environment.sessionVariables._JAVA_AWT_WM_NONREPARENTING = lib.mkIf cfg.sway.enable "1";

    # For Gnome Disks
    services.udisks2.enable = cfg.sway.enable;

    # For auto mounting in Nautilus and Thunar
    services.gvfs.enable = cfg.sway.enable;
    services.dbus.enable = cfg.sway.enable;

    # Don’t shutdown when power button is short-pressed
    services.logind.extraConfig = lib.optionalString cfg.sway.enable ''
      HandlePowerKey=ignore
    '';
    services.blueman.enable = cfg.sway.enable;

    security.pam.services.gtklock = lib.mkIf cfg.sway.enable { };
    security.pam.services.hyprlock = lib.mkIf cfg.sway.enable { };
    security.pam.services.waylock = lib.mkIf cfg.sway.enable { };

    services.displayManager.cosmic-greeter.enable = cfg.greeter == "cosmic";

    # buggy https://github.com/rharish101/ReGreet/issues/45
    programs.regreet = {
      enable = cfg.greeter == "regreet";
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

    # Stolen from https://github.com/sjcobb2022/nixos-config/blob/aa74d65ebb9ec49316b1f3a693176ae37381712e/hosts/common/optional/greetd.nix
    services.greetd = {
      enable = (cfg.greeter != null);
      settings = lib.optionalAttrs (cfg.greeter == "tuigreet") {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --remember-session";
          user = "greeter";
        };
      };
    };

    systemd.services.greetd.serviceConfig = lib.mkIf (cfg.greeter == "tuigreet") {
      Type = "idle";
      StandardInput = "tty";
      StandardOutput = "tty";
      StandardError = "journal"; # Without this errors will spam on screen
      # Without these bootlogs will spam on screen
      TTYReset = true;
      TTYVHangup = true;
      TTYVTDisallocate = true;
    };
  };
}
