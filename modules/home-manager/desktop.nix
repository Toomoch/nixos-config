{
  config,
  pkgs,
  lib,
  self,
  ...
}:
{
  options.custom.desktop = {
    enable = lib.mkEnableOption "Whether to enable desktop stuff";
  };
  config = lib.mkIf config.custom.desktop.enable {
    home.packages = with pkgs; [
    ];

    xdg = {
      enable = true;
      userDirs = {
        enable = true;
        createDirectories = true;
      };
    };

    home.pointerCursor = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 24;
      x11 = {
        enable = true;
        defaultCursor = "Adwaita";
      };
      gtk.enable = true;
    };

    gtk = {
      enable = true;
      theme = {
        name = "adw-gtk3-dark";
        package = pkgs.adw-gtk3;
      };
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
      cursorTheme = {
        name = "Adwaita";
        package = pkgs.adwaita-icon-theme;
      };
      font = {
        name = "sans";
        # package = pkgs.rubik;
        size = 11;
      };
    };

    xresources.properties = {
      "Xft.antialias" = 1;
      "Xft.autohint" = 0;
      "Xft.hinting" = 1;
      "Xft.hintstyle" = "hintnone";
      "Xft.rgba" = "rgb";
      "Xft.lcdfilter" = "lcddefault";
    };

  };
}
