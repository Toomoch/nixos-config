{
  config,
  flake-root,
  pkgs,
  lib,
  ...
}:
let
  font = "Rubik";
in
{

  options.custom.wl = {
    enable = lib.mkEnableOption "Whether to enable wl stuff";
  };
  config = lib.mkIf config.custom.wl.enable {
    home.packages = with pkgs; [
      jq
      wl-clipboard
      swaynotificationcenter
      polkit_gnome
      networkmanagerapplet
      fuzzel
      brightnessctl
      wayvnc
      wpaperd
      gtklock
      gtklock-userinfo-module
      gtklock-powerbar-module
      blueman
      swayosd
    ];

    # removes close button from gtk apps
    dconf.settings = {
      "org/gnome/desktop/wm/preferences" = {
        button-layout = "appmenu";
      };
    };

    xdg.configFile."wpaperd/wallpaper.toml".text = ''
      [default]
      path = "${config.xdg.userDirs.pictures}/wallpapers"
      duration = "5m"
    '';

    xdg.configFile."gtklock/config.ini".text = ''
      [main]
      modules=${pkgs.gtklock-powerbar-module}/lib/gtklock/powerbar-module.so;
      background=${/${flake-root}/assets/lockscreen.png};
    '';

    xdg.configFile."fuzzel/fuzzel.ini".text = ''
      font=${font}
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
