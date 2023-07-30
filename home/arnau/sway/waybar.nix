{ config, pkgs, lib, ... }:

{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        height = 30;
        spacing = 4;
        modules-left = [ "sway/workspaces" "sway/mode" "sway/window" ];
        modules-center = [ "custom/media" ];
        modules-right = [
          "tray"
          "pulseaudio"
          "network"
          "cpu"
          "memory"
          "temperature"
          "backlight"
          "keyboard-state"
          "battery"
          "clock"
          "custom/power"
        ];
        "keyboard-state" = {
          "numlock" = true;
          "capslock" = true;
          "format" = "{name} {icon}";
          "format-icons" = {
            "locked" = "";
            "unlocked" = "";
          };
        };
        "sway/mode" = { "format" = ''<span style="italic">{}</span>''; };
        "sway/window" = {
          "format" = "{title}";
          "max-length" = 50;
          "icon" = true;
        };
        "hyprland/window" = {
          "format" = "{}";
          "separate-outputs" = true;
          "max-length" = 200;
        };
        "tray" = { "spacing" = 10; };
        "clock" = {
          "tooltip-format" = ''
            <big>{:%Y %B}</big>
            <tt><small>{calendar}</small></tt>'';
          "format-alt" = "{:%d-%m-%Y}";
        };
        "cpu" = {
          "format" = " {usage}% ";
        };
        "memory" = { "format" = "{}% "; };
        "temperature" = {
          "critical-threshold" = 80;
          "format" = "{temperatureC}°C {icon}";
          "format-icons" = [ "" "" "" ];
        };
        "backlight" = {
          "format" = "{percent}% {icon}";
          "format-icons" = [ "" "" ];
        };
        "battery" = {
          "states" = {
            "warning" = 30;
            "critical" = 15;
          };
          "format" = "{capacity}% {icon}";
          "format-charging" = "{capacity}% ";
          "format-plugged" = "{capacity}% ";
          "format-alt" = "{time} {icon}";
          "format-icons" = [ "" "" "" "" "" ];
        };
        "network" = {
          "format-wifi" = "{essid} ({signalStrength}%) ";
          "format-ethernet" = "{ipaddr}/{cidr} ";
          "tooltip-format" = "{ifname} via {gwaddr} ";
          "format-linked" = "{ifname} (No IP) ";
          "format-disconnected" = "Disconnected ⚠";
          "format-alt" = "{ifname}: {ipaddr}/{cidr}";
        };
        "pulseaudio" = {
          "format" = "{volume}% {icon} {format_source}";
          "format-bluetooth" = "{volume}% {icon} {format_source}";
          "format-bluetooth-muted" = " {icon} {format_source}";
          "format-muted" = " {format_source}";
          "format-source" = "{volume}% ";
          "format-source-muted" = "";
          "format-icons" = {
            "headphone" = "";
            "hands-free" = "";
            "headset" = "";
            "phone" = "";
            "portable" = "";
            "car" = "";
            "default" = [ "" "" "" ];
          };
          "on-click" = "pavucontrol";
        };
        "custom/power" = {
          "format" = "";
          "on-click" =
            "swaynag -t warning -m ' Power Menu' -z 'Lock' 'gtklock -d' -z 'Logout' 'swaymsg exit || hyprctl dispatch exit' -z 'Suspend' 'systemctl suspend' -z 'Poweroff' 'systemctl poweroff' -z 'Reboot' 'systemctl reboot' -z 'Reboot to UEFI' 'systemctl reboot --firmware-setup' -z 'Reboot to Windows' 'systemctl reboot --boot-loader-entry=auto-windows' --background=#00000033 --text=#FFFFFF --button-text=#FFFFFF --button-background=#00000033 --button-border=#000000 --border-bottom-size=0 --message-padding=0";
        };
      };
    };

    style = builtins.readFile (./waybar-style.css);
  };
}
