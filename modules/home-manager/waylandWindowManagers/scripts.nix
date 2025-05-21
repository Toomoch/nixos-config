{
  pkgs,
  config,
  lib,
  ...
}:
let
  wl-screenshot = pkgs.writeShellApplication {
    name = "wl-screenshot";
    runtimeInputs = [
      pkgs.slurp
      pkgs.grim
      pkgs.jq
      pkgs.wl-clipboard
      pkgs.libnotify
      pkgs.xdg-user-dirs
    ];
    text = ''
      #!/usr/bin/env bash

      filename=$(xdg-user-dir PICTURES)/screenshots/$(date +'screenshot_%Y%m%d_%H%M%S.png')

      case "$1" in
          area)
              slurpout=$(slurp)
              if [ -z "$slurpout" ]; then
                  exit
              else
                  grim -g "$slurpout" - | wl-copy --type image/png && wl-paste > "$filename"
              fi
          ;;
          output)
              slurpout=$(slurp -o -f "%o")
              if [ -z "$slurpout" ]; then
                  exit
              else
                  grim -o "$slurpout" - | wl-copy --type image/png && wl-paste > "$filename"
              fi
          ;;
          window)
              grim -g "$(swaymsg -t get_tree | jq -j '.. | select(.type?) | select(.focused).rect | "\(.x),\(.y) \(.width)x\(.height)"')" - | wl-copy --type image/png && wl-paste > "$filename"
          ;;
      esac
      notify-send -i "$filename" "Screenshot tool" "Screenshot saved to $filename and copied to clipboard"
    '';
  };

  fuzzelpoweroffmenu = pkgs.writeShellApplication {
    name = "fuzzelpoweroffmenu";
    runtimeInputs = [
      pkgs.fuzzel
    ];
    text = ''
      #!/usr/bin/env bash

      options="  Power Off
        Reboot
        Suspend
        Log Out
        Lock
        Reboot to UEFI
        Reboot to Windows"

      chosen=$(echo -e "$options" | fuzzel --no-exit-on-keyboard-focus-loss --dmenu --font="NotoSansM Nerd Font Mono:size=20")

      case "$chosen" in
      "  Power Off")
              systemctl poweroff
              ;;
      "  Reboot")
              systemctl reboot
              ;;
      "  Suspend")
              systemctl suspend
              ;;
      "  Log Out")
              swaymsg exit || riverctl exit || hyprctl dispatch exit
              ;;
      "  Lock")
              waylock
              ;;
      "  Reboot to UEFI")
              systemctl reboot --firmware-setup
              ;;
      "  Reboot to Windows")
              systemctl reboot --boot-loader-entry=auto-windows
              ;;
      *) ;;
      esac
    '';

  };
in
{
  home.packages = lib.optionals config.custom.wl.enable [
    fuzzelpoweroffmenu
    wl-screenshot
  ];

}
