{ config, pkgs, lib, ... }:
let
  screenshot = pkgs.writeShellScriptBin "screenshot"
    (builtins.readFile ./swayscreenshot.sh);
  font = "Rubik";
  kanshi_assign_sway = pkgs.writeShellScriptBin "kanshi_assign_sway"
    (builtins.readFile ../dotfiles/kanshi_assign_sway.sh);

  fuzzelpoweroffmenu = pkgs.writeShellScriptBin "fuzzelpoweroffmenu"
    (builtins.readFile ../dotfiles/powermenu.sh);
  filemanager = "thunar";
  browser = "firefox";
in {
  imports = [ ./waybar.nix ];

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
    kanshi_assign_sway
    kanshi
    fuzzelpoweroffmenu
  ];

  wayland.windowManager.river = {

    enable = true;
    package = null;
    settings = {
      keyboard-layout = "-model pc105 -variant '' -options caps:escape es";
      default-layout = "rivertile";
      map.normal = {
        "Super Return" = "spawn 'alacritty'";
        "Super Up" = "focus-view up";
        "Super Down" = "focus-view down";
        "Super Left" = "focus-view left";
        "Super Right" = "focus-view right";
        "Super K" = "focus-view up";
        "Super J" = "focus-view down";
        "Super H" = "focus-view left";
        "Super L" = "focus-view right";
        "Super F" = "toggle-fullscreen";
        "Super+Shift Q" = "close";
        "None XF86MonBrightnessDown" =
          "spawn 'swayosd-client --brightness lower'";
        "None XF86MonBrightnessUp" =
          "spawn 'swayosd-client --brightness raise'";
        "None XF86AudioRaiseVolume" =
          "spawn 'swayosd-client --output-volume raise'";
        "None XF86AudioLowerVolume" =
          "spawn 'swayosd-client --output-volume lower'";
        "None XF86AudioMute" =
          "spawn 'swayosd-client --output-volume mute-toggle'";
        "None XF86AudioMicMute" =
          "spawn 'wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle'";
        "None XF86AudioPlay" = "spawn 'playerctl play-pause'";
        "None XF86AudioNext" = "spawn 'playerctl next'";
        "None XF86AudioPrev" = "spawn 'playerctl previous'";
        "Super E" = "spawn '${filemanager}'";
        "Super D" = "spawn 'fuzzel'";

        # Screenshots
        "Print" = "spawn 'screenshot area'";
        "Super Print" = "spawn 'screenshot output'";
        "Shift Print" = "spawn 'screenshot window'";
      };
      spawn = [
        "rivertile"
        "wpaperd"
        "nm-applet --indicator"
        "swaync"
        browser
        "swayosd-server"
        "waybar"
      ];
      extraConfig = ''

        for i in $(seq 1 9)
        do
            tags=$((1 << ($i - 1)))

            # Super+[1-9] to focus tag [0-8]
            riverctl map normal Super $i set-focused-tags $tags

            # Super+Shift+[1-9] to tag focused view with tag [0-8]
            riverctl map normal Super+Shift $i set-view-tags $tags

            # Super+Control+[1-9] to toggle focus of tag [0-8]
            riverctl map normal Super+Control $i toggle-focused-tags $tags

            # Super+Shift+Control+[1-9] to toggle tag [0-8] of focused view
            riverctl map normal Super+Shift+Control $i toggle-view-tags $tags
        done
      '';
    };
  };

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
        #{ command = "killall yambar && yambar"; always = true; }
        { command = "nm-applet --indicator"; }
        { command = "blueman-applet"; }
        { command = "wpaperd"; }
        { command = "autotiling-rs"; }
        { command = "rfkill block bluetooth"; }
        { command = "swaync"; }
        { command = browser; }
        {
          command =
            "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        }
        { command = "swayidle -w before-sleep 'gtklock -d'"; }
        { command = "swayosd-server"; }

      ];
      menu = "fuzzel";
      keybindings = lib.mkOptionDefault {
        # Apps
        "${modifier}+e" = "exec ${filemanager}";

        # Screenshots
        "print" = "exec screenshot area";
        "${modifier}+print" = "exec screenshot output";
        "Shift+print" = "exec screenshot window";

        # Media
        "XF86MonBrightnessDown" = "exec swayosd-client --brightness lower";
        "XF86MonBrightnessUp" = "exec swayosd-client --brightness raise";
        "XF86AudioRaiseVolume" = "exec swayosd-client --output-volume raise";
        "XF86AudioLowerVolume" = "exec swayosd-client --output-volume lower";
        "XF86AudioMute" = "exec swayosd-client --output-volume mute-toggle";
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
        "type:keyboard" = {
          xkb_layout = "es";
          xkb_options = "caps:escape";
        };

        "type:touchpad" = {
          natural_scroll = "enabled";
          dwt = "enabled";
          tap = "enabled";
          accel_profile = "adaptive";
          middle_emulation = "enabled";
        };

        "type:pointer" = { accel_profile = "flat"; };

        "2:7:SynPS/2_Synaptics_TouchPad" = { pointer_accel = "0.2"; };

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
    extraOptions = [ "--unsupported-gpu" ];

    swaynag = {
      enable = true;
      settings = { "<config>" = { font = "${font} 12"; }; };
    };
  };

  dconf.settings = {
    "org/gnome/desktop/wm/preferences" = { button-layout = "appmenu"; };
  };

  xdg.configFile."wpaperd/wallpaper.toml".text = ''
    [default]
    path = "${config.xdg.userDirs.pictures}/wallpapers"
    duration = "5m"
  '';

  xdg.configFile."gtklock/config.ini".text = ''
    [main]
    modules=${pkgs.gtklock-powerbar-module}/lib/gtklock/powerbar-module.so;
    background=${../../system/assets/lockscreen.png};
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
