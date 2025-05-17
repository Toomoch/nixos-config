{
  config,
  pkgs,
  lib,
  ...
}:
let

in
{
  options.custom.wl.waybar = {
    enable = lib.mkEnableOption "Whether to enable waybar stuff";
  };
  config = lib.mkIf config.custom.wl.waybar.enable {
    programs.waybar = {
      enable = true;
      settings = {
        mainBar = {
          layer = "top";
          height = 30;
          spacing = 1;
          modules-left =
            lib.lists.optionals config.wayland.windowManager.sway.enable [
              "sway/workspaces"
              "sway/mode"
              "sway/window"
            ]
            ++ lib.lists.optionals config.wayland.windowManager.river.enable [
              "river/tags"
              "river/window"
              "river/layout"
            ];
          modules-center = [ ];
          modules-right = [
            "tray"
            "pulseaudio"
            "network"
            "cpu"
            "memory"
            "temperature"
            "backlight"
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
          "sway/mode" = {
            "format" = ''<span style="italic">{}</span>'';
          };
          "sway/window" = {
            "format" = "{title}";
            "max-length" = 50;
            "icon" = true;
          };
          "river/window" = {
            "max-length" = 50;
          };
          "hyprland/window" = {
            "format" = "{}";
            "separate-outputs" = true;
            "max-length" = 200;
          };
          "tray" = {
            "spacing" = 10;
          };
          "clock" = {
            "format" = "{:%d/%m/%y %H:%M}  ";
            "format-alt" = "{:%A, %B %d, %Y (%R)}";
            "tooltip-format" = "<tt><small>{calendar}</small></tt>";
            "calendar" = {
              "mode" = "year";
              "mode-mon-col" = 3;
              "weeks-pos" = "right";
              "on-scroll" = 1;
              "format" = {
                "months" = "<span color='#ffead3'><b>{}</b></span>";
                "days" = "<span color='#ecc6d9'><b>{}</b></span>";
                "weeks" = "<span color='#99ffdd'><b>W{}</b></span>";
                "weekdays" = "<span color='#ffcc66'><b>{}</b></span>";
                "today" = "<span color='#ff6699'><b><u>{}</u></b></span>";
              };
            };
            "actions" = {
              "on-click-right" = "mode";
              "on-click-forward" = "tz_up";
              "on-click-backward" = "tz_down";
              "on-scroll-up" = "shift_up";
              "on-scroll-down" = "shift_down";
            };
          };
          "cpu" = {
            "format" = " {usage}% ";
          };
          "memory" = {
            "format" = "{}% ";
          };
          "temperature" = {
            "critical-threshold" = 80;
            "format" = "{temperatureC}°C {icon}";
            "format-icons" = [
              ""
              ""
              ""
            ];
          };
          "backlight" = {
            "format" = "{percent}% {icon}";
            "format-icons" = [
              ""
              ""
            ];
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
            "format-icons" = [
              ""
              ""
              ""
              ""
              ""
            ];
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
              "default" = [
                ""
                ""
                ""
              ];
            };
            "on-click" = "pavucontrol";
          };
          "custom/power" = {
            "format" = "";
            "on-click" = "fuzzelpoweroffmenu";
          };
        };
      };

      style = builtins.readFile (./waybar-style.css);
    };
  };
}
