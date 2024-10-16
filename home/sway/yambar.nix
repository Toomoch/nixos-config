{ pkgs, config, lib, ... }:
{
  options.yambar = {
    enable = lib.mkEnableOption ("Enable yambar");
    battery = lib.mkOption {
      default = "BAT0";
      example = "BAT1";
      description = ''
        Battery name in /sys/class/power_supply/ 
      '';
      type = lib.types.str;
    };
    ethernet = lib.mkOption {
      default = "enp1s0";
      example = "enp1s0";
      description = ''
        Ethernet interface name 
      '';
      type = lib.types.str;
    };
  };
  config = lib.mkIf config.yambar.enable {

    home.packages = with pkgs; [
      yambar
      killall
    ];
    xdg.configFile."yambar/config.yml".text = ''
  
# Typical laptop setup, with wifi, brightness, battery etc, for
# i3/Sway.

# For X11/i3, you'll want to replace calls to swaymsg with i3-msg, and
# the sway-xkb module with the xkb module.

# fonts we'll be re-using here and there
awesome: &awesome Font Awesome 6 Free:style=solid:pixelsize=14
awesome_brands: &awesome_brands Font Awesome 6 Brands:pixelsize=16

std_underline: &std_underline {underline: { size: 2, color: ff0000ff}}

# This is THE bar configuration
bar:
  height: 26
  location: top
  spacing: 5
  margin: 7

  # Default font
  font: Rubik:pixelsize=14

  foreground: ffffffff
  background: 111111cc

  border:
    width: 1
    color: 999999cc
    margin: 5
    top-margin: 0

  left:
    - i3:
        sort: native
        anchors: # Not used (directly) by f00bar; used here to avoid duplication
          - string: &i3_common {margin: 5, on-click: "swaymsg --quiet workspace {name}"}
          - string: &default {<<: *i3_common, text: "{name}"}
          - focused: &focused
              deco: {stack: [background: {color: ffa0a04c}, <<: *std_underline]}
          - invisible: &invisible {foreground: ffffff55}
          - urgent: &urgent
              foreground: 000000ff
              deco: {stack: [background: {color: bc2b3fff}, <<: *std_underline]}
          - map: &i3_mode
              default:
                - string:
                    margin: 5
                    text: "{mode}"
                    deco: {background: {color: cc421dff}}
                - empty: {right-margin: 7}
              conditions:
                mode == default: {empty: {}}
        content:
          "":
            map:
              conditions:
                state == focused:   {string: {<<: [*default, *focused]}}
                state == unfocused: {string: {<<: *default}}
                state == invisible: {string: {<<: [*default, *invisible]}}
                state == urgent:    {string: {<<: [*default, *urgent]}}
    - foreign-toplevel:
        content:
          map:
            conditions:
              ~activated: {empty: {}}
              activated:
                - string: {text: "{app-id}", foreground: ffa0a0ff}
                - string: {text: ": {title}"}

  right:
    - removables:
        anchors:
          drive: &drive { text: , font: *awesome}
          optical: &optical {text: , font: *awesome}
        spacing: 5
        content:
          map:
            conditions:
              ~mounted:
                map:
                  on-click: udisksctl mount -b {device}
                  conditions:
                    ~optical: [{string: *drive}, {string: {text: "{label}"}}]
                    optical: [{string: *optical}, {string: {text: "{label}"}}]
              mounted:
                map:
                  on-click: udisksctl unmount -b {device}
                  conditions:
                    ~optical:
                      - string: {<<: *drive, deco: *std_underline}
                      - string: {text: "{label}"}
                    optical:
                      - string: {<<: *optical, deco: *std_underline}
                      - string: {text: "{label}"}
    - sway-xkb:
        identifiers: [1:1:AT_Translated_Set_2_keyboard]
        content:
          - string: {text: , font: *awesome}
          - string: {text: "{layout}"}
    - network:
        name: ${config.yambar.ethernet}
        content:
          map:
            conditions:
              ~carrier: {empty: {}}
              carrier:
                map:
                  default: {string: {text: , font: *awesome, foreground: ffffff66}}
                  conditions:
                    state == up && ipv4 != "": {string: {text: , font: *awesome}}
    - network:
        name: wlp2s0
        poll-interval: 1000
        content:
          map:
            default: {string: {text: , font: *awesome, foreground: ffffff66}}
            conditions:
              state == down: {string: {text: , font: *awesome, foreground: ff0000ff}}
              state == up:
                map:
                  default:
                    - string: {text: , font: *awesome}
                    - string: {text: "{ssid} {signal} dBm"}

                  conditions:
                    ipv4 == "":
                      - string: {text: , font: *awesome, foreground: ffffff66}
                      - string: {text: "{ssid} {signal} dBm", foreground: ffffff66}
    - pipewire:
        anchors:
          volume: &volume
            conditions:
              muted: {string: {text: "{linear_volume}%", foreground: ff0000ff}}
              ~muted: {string: {text: "{linear_volume}%"}}
        content:
          list:
            items:
              - map:
                  on-click: pavucontrol
                  conditions:
                    type == "sink":
                      map:
                        conditions:
                          icon == "audio-headset-bluetooth":
                            string: {text: "  "}
                        default:
                          - ramp:
                              tag: linear_volume
                              items:
                                - string: {text: "  "}
                                - string: {text: "  "}
                                - string: {text: "  "}
                    type == "source":
                      - string: {text: "  "}
              - map:
                  <<: *volume
    - backlight:
        name: intel_backlight
        content: [ string: {text:  , font: *awesome}, string: {text: "{percent}%"}]
    - battery:
        name: BAT1
        poll-interval: 30000
        anchors:
          discharging: &discharging
            list:
              items:
                - ramp:
                    tag: capacity
                    items:
                      - string: {text: , foreground: ff0000ff, font: *awesome}
                      - string: {text: , foreground: ffa600ff, font: *awesome}
                      - string: {text: , font: *awesome}
                      - string: {text: , font: *awesome}
                      - string: {text: , font: *awesome}
                      - string: {text: , font: *awesome}
                      - string: {text: , font: *awesome}
                      - string: {text: , font: *awesome}
                      - string: {text: , font: *awesome}
                      - string: {text: , foreground: 00ff00ff, font: *awesome}
                - string: {text: "{capacity}% {estimate}"}
        content:
          map:
            conditions:
              state == unknown:
                <<: *discharging
              state == discharging:
                <<: *discharging
              state == charging:
                - string: {text: , foreground: 00ff00ff, font: *awesome}
                - string: {text: "{capacity}% {estimate}"}
              state == full:
                - string: {text: , foreground: 00ff00ff, font: *awesome}
                - string: {text: "{capacity}% full"}
              state == "not charging":
                - ramp:
                    tag: capacity
                    items:
                      - string: {text:  , foreground: ff0000ff, font: *awesome}
                      - string: {text:  , foreground: ffa600ff, font: *awesome}
                      - string: {text:  , foreground: 00ff00ff, font: *awesome}
                      - string: {text:  , foreground: 00ff00ff, font: *awesome}
                      - string: {text:  , foreground: 00ff00ff, font: *awesome}
                      - string: {text:  , foreground: 00ff00ff, font: *awesome}
                      - string: {text:  , foreground: 00ff00ff, font: *awesome}
                      - string: {text:  , foreground: 00ff00ff, font: *awesome}
                      - string: {text:  , foreground: 00ff00ff, font: *awesome}
                      - string: {text:  , foreground: 00ff00ff, font: *awesome}
                - string: {text: "{capacity}%"}
    - clock:
        time-format: "%H:%M"
        content:
          - string: {text: , font: *awesome}
          - string: {text: "{date}", right-margin: 5}
          - string: {text: , font: *awesome}
          - string: {text: "{time}"}
    - label:
        content:
          string:
            on-click: swaynag -t warning -m ' Power Menu' -z 'Lock' 'gtklock -d' -z 'Logout' 'swaymsg exit || hyprctl dispatch exit' -z 'Suspend' 'systemctl suspend' -z 'Poweroff' 'systemctl poweroff' -z 'Reboot' 'systemctl reboot' -z 'Reboot to UEFI' 'systemctl reboot --firmware-setup' -z 'Reboot to Windows' 'systemctl reboot --boot-loader-entry=auto-windows' --background=#00000033 --text=#FFFFFF --button-text=#FFFFFF --button-background=#00000033 --button-border=#000000 --border-bottom-size=0 --message-padding=0
            text: 
            font: *awesome

            '';
  };
}
