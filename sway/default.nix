{ config, pkgs, lib, ... }:

{
  imports = [
    ./waybar.nix
  ];

  home.packages = with pkgs; [
    sway-contrib.grimshot
    grim
    slurp
    wl-clipboard
    swaynotificationcenter
    autotiling-rs
    polkit_gnome
    networkmanagerapplet
    fuzzel
  ];


  wayland.windowManager.sway = {
    enable = true;
    xwayland = true;
    config = rec {
      modifier = "Mod4";
      terminal = "alacritty";

      fonts = {
        names = [ "Rubik" ];
        size = 12.0;
      };

      floating.titlebar = true;

      gaps.inner = 5;
      output = {
        "*" = {
          bg =
            "`find /home/arnau/Pictures/wallpapers -type f | shuf -n 1` fill";
        };
      };
      startup = [
        { command = "nm-applet --indicator"; }
        { command = "blueman-applet"; }
        { command = "wpaperd"; }
        { command = "autotiling-rs"; }
        { command = "rfkill block bluetooth"; }
        { command = "swaync"; }
        { command = "firefox"; }
        {
          command =
            "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        }
        { command = "oversteer --range 300"; }

      ];
      menu = "fuzzel";
      keybindings = lib.mkOptionDefault {
        # Apps
        "${modifier}+e" = "exec thunar";

        # Screenshots
        "print" = "exec grimshot copy area";
        "${modifier}+print" =
          "exec grimshot save area $(xdg-user-dir PICTURES)/$(date +'screenshot_%Y%m%d_%H%M%S.png')";

        # Media
        "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";
        "XF86MonBrightnessUp" = "exec brightnessctl set 5%+";
        "XF86AudioRaiseVolume" =
          "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
        "XF86AudioLowerVolume" =
          "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        "XF86AudioMicMute" =
          "exec wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        "XF86AudioPlay" = "exec playerctl play-pause";
        "XF86AudioNext" = "exec playerctl next";
        "XF86AudioPrev" = "exec playerctl previous";

        # Notifications
        "${modifier}+Shift+n" = "exec swaync-client -t -sw";

      };
      input = {
        "type:keyboard" = { xkb_layout = "es"; };

        "type:touchpad" = {
          natural_scroll = "enabled";
          dwt = "enabled";
          tap = "enabled";
          accel_profile = "adaptive";
          middle_emulation = "enabled";
        };

        "type:pointer" = { accel_profile = "flat"; };

        "2:7:SynPS/2_Synaptics_TouchPad" = { pointer_accel = "0.3"; };

        "4152:5929:SteelSeries_SteelSeries_Rival_110_Gaming_Mouse" = {
          pointer_accel = "0.2";
        };

        "1356:3302:Sony_Interactive_Entertainment_Wireless_Controller_Touchpad" =
          {
            pointer_accel = "0.1";
          };

        "1356:3302:Wireless_Controller_Touchpad" = { pointer_accel = "0.1"; };
      };
      bars = [{ command = "waybar"; }];

    };

    extraConfig = ''
      include /etc/sway/config.d/*
    '';

    swaynag = {
      enable = true;
      settings = {
        "default" = {
          font = "Rubik 12";
        };
      };
    };

  };

  programs.swaylock.settings = {
    image = "`find $HOME/Pictures/wallpapers -type f | shuf -n 1`";
    font = "Rubik";
    daemonize = true;
  };



}
