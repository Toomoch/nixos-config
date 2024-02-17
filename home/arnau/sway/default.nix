{ config, pkgs, lib, ... }:
let
  screenshot = pkgs.writeShellScriptBin "screenshot" (builtins.readFile (./swayscreenshot.sh));
  font = "Rubik";
in
{
  imports = [
    ./waybar.nix
  ];

  home.packages = with pkgs; [
    jq
    grim
    slurp
    wl-clipboard
    screenshot
    swaynotificationcenter
    autotiling-rs
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
    xdg-user-dirs
    libnotify
    swayosd
    nwg-displays
  ];

  wayland.windowManager.sway = {
    enable = true;
    xwayland = true;
    wrapperFeatures.gtk = true;
    config = rec {
      modifier = "Mod4";
      terminal = "alacritty";

      fonts = {
        names = [ "${font}" ];
        size = 12.0;
      };

      defaultWorkspace = "workspace number 1";

      window.titlebar = false;
      floating.titlebar = true;
      colors.focused = {
        border = "#00fffaff";
        background = "#00fffaff";
        text = "#000000";
        indicator = "#017a78ff";
        childBorder = "#00fffaff";
      };
      colors.unfocused = {
        border = "#333333";
        background = "#222222";
        text = "#888888";
        indicator = "#292d2e";
        childBorder = "#00000000";
      };
      colors.focusedInactive = {
        border = "#333333";
        background = "#5f676a";
        text = "#ffffff";
        indicator = "#484e50";
        childBorder = "#00000000";
      };
      gaps.inner = 5;
      output = { };
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
        { command = "swayidle -w before-sleep 'gtklock -d'"; }
        { command = "swayosd"; }

      ];
      menu = "fuzzel";
      keybindings = lib.mkOptionDefault {
        # Apps
        "${modifier}+e" = "exec nautilus";

        # Screenshots
        "print" = "exec screenshot area";
        "${modifier}+print" = "exec screenshot output";
        "Shift+print" = "exec screenshot window";

        # Media
        "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";
        "XF86MonBrightnessUp" = "exec brightnessctl set 5%+";
        "XF86AudioRaiseVolume" =
          "exec swayosd --output-volume raise";
        "XF86AudioLowerVolume" =
          "exec swayosd --output-volume lower";
        "XF86AudioMute" = "exec swayosd --output-volume mute-toggle";
        "XF86AudioMicMute" =
          "exec wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        "XF86AudioPlay" = "exec playerctl play-pause";
        "XF86AudioNext" = "exec playerctl next";
        "XF86AudioPrev" = "exec playerctl previous";

        # Notifications
        "${modifier}+Shift+n" = "exec swaync-client -t -sw";

        # Workspace back and forth
        "${modifier}+Tab" = "workspace back_and_forth";

        # Lock
        "${modifier}+Escape" = "exec gtklock -d";

        "${modifier}+Shift+s" = "sticky toggle";

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

        "1356:3302:Sony_Interactive_Entertainment_Wireless_Controller_Touchpad" = {
          pointer_accel = "0.1";
        };

        "1356:3302:Wireless_Controller_Touchpad" = { pointer_accel = "0.1"; };
      };
      bars = [{ command = "waybar"; }];

    };

    extraConfig = ''
      include /etc/sway/config.d/*
    '';
    extraOptions = [ "--unsupported-gpu" ];

    swaynag = {
      enable = true;
      settings = {
        "<config>" = {
          font = "${font} 12";
        };
      };
    };
  };

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
    background=${../../../system/assets/lockscreen.png};
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


}
