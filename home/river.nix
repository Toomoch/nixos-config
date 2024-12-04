{ pkgs, ... }:
let
  filemanager = "thunar";
  browser = "firefox";
in
{
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
        "None Print" = "spawn 'screenshot area'";
        "Super Print" = "spawn 'screenshot output'";
        "Shift Print" = "spawn 'screenshot window'";
      };
      spawn = [
        "rivertile"
        "wpaperd"
        "swaync"
        browser
        "swayosd-server"
        "waybar"
        "'nm-applet --indicator'"
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


}
