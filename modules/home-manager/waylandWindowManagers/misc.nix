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
      jq
      wl-clipboard
      fuzzel
      brightnessctl
      wayvnc
      gtklock
      gtklock-userinfo-module
      gtklock-powerbar-module
      swayosd
      obs-studio
    ];

    services.swaync.enable = true;
    programs.waybar = {
      enable = true;
      systemd.enable = true;
    };
    services.blueman-applet.enable = true;
    services.network-manager-applet.enable = true;
    services.wpaperd = {
      enable = true;
      settings.default = {
        path = "${config.xdg.userDirs.pictures}/wallpapers";
        duration = "5m";
      };
    };
    services.polkit-gnome.enable = true;
    services.swayidle = {
      enable = true;
      events = [
        { event = "before-sleep"; command = "${pkgs.swaylock}/bin/swaylock -fF"; }
      ];
      timeouts = [
        { timeout = 15 * 60; command = "${pkgs.swaylock}/bin/swaylock -fF"; }
      ];
    };

    # removes close button from gtk apps
    dconf.settings = {
      "org/gnome/desktop/wm/preferences" = {
        button-layout = "appmenu";
      };
    };

    # xdg.configFile."wpaperd/wallpaper.toml".text = ''
    #   [default]
    #   path = "${config.xdg.userDirs.pictures}/wallpapers"
    #   duration = "5m"
    # '';

    xdg.configFile."gtklock/config.ini".text = ''
      [main]
      modules=${pkgs.gtklock-powerbar-module}/lib/gtklock/powerbar-module.so;
      background=${/${flake-root}/assets/lockscreen.png};
    '';

    xdg.configFile."fuzzel/fuzzel.ini".text = ''
      font=sans
      dpi-aware=auto
      icon-theme="Papirus-Dark"

      [colors]
      background=00000080
      text=ffffffff
      match=cb4b16ff
      selection=00fffaff
      selection-text=000000ff
      border=00fffaff
    '';
  };

}
