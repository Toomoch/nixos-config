{ inputs, config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
   # inputs.matugen.packages.${system}.default
   # bun
   # swww
   # fd
   # dart-sass
  ];

  #
  imports = [
    ../sway/waybar.nix
    #inputs.ags.homeManagerModules.default
  ];

  #programs.ags = {
  #  enable = true;
  #  configDir = ../ags;
  #  # extraPackages = with pkgs; [
  #  #   accountsservice
  #  # ];
  #};

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    settings = {
      "$mod" = "SUPER";
      general = {
        gaps_in = 5;
        gaps_out = 5;
        border_size = 1;
        "col.active_border" = "rgba(88888888)";
        "col.inactive_border" = "rgba(00000088)";

        allow_tearing = true;
        resize_on_border = true;
      };

      monitor = [ "eDP-1,preferred,auto,1" ];
      input = {
        kb_layout = "es";

        # focus change on cursor move
        follow_mouse = 1;
        accel_profile = "flat";
        touchpad = {
          scroll_factor = 0.7;
          natural_scroll = true;

        };
      };

      gestures = {
        workspace_swipe = true;
        workspace_swipe_forever = true;
      };

      bind =
        let
          launcher = "fuzzel";
          terminal = "alacritty";
        in
        [
          # compositor commands
          "$mod SHIFT, E, exec, pkill Hyprland"
          "$mod SHIFT, Q, killactive,"
          "$mod, F, fullscreen,"
          "$mod, G, togglegroup,"
          "$mod, D, exec, ${launcher}"
          "$mod SHIFT, N, changegroupactive, f"
          "$mod SHIFT, P, changegroupactive, b"
          "$mod, R, togglesplit,"
          "$mod SHIFT, SPACE, togglefloating,"
          "$mod, P, pseudo,"
          "$mod ALT, ,resizeactive,"
          "$mod, Return, exec, ${terminal}"

          "$mod, left, movefocus, l"
          "$mod, right, movefocus, r"
          "$mod, up, movefocus, u"
          "$mod, down, movefocus, d"

          "$mod, 1, workspace, 1"
          "$mod, 2, workspace, 2"
          "$mod, 3, workspace, 3"
          "$mod, 4, workspace, 4"
          "$mod, 5, workspace, 5"
          "$mod, 6, workspace, 6"
          "$mod, 7, workspace, 7"
          "$mod, 8, workspace, 8"
          "$mod, 9, workspace, 9"
          "$mod, 0, workspace, 10"

          "$mod SHIFT, 1, movetoworkspace, 1"
          "$mod SHIFT, 2, movetoworkspace, 2"
          "$mod SHIFT, 3, movetoworkspace, 3"
          "$mod SHIFT, 4, movetoworkspace, 4"
          "$mod SHIFT, 5, movetoworkspace, 5"
          "$mod SHIFT, 6, movetoworkspace, 6"
          "$mod SHIFT, 7, movetoworkspace, 7"
          "$mod SHIFT, 8, movetoworkspace, 8"
          "$mod SHIFT, 9, movetoworkspace, 9"
          "$mod SHIFT, 0, movetoworkspace, 10"
        ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

    };
    # extraConfig = ''
    #   exec-once = wpaperd
    #   exec-once = swaync
    #   exec-once = waybar
    #   exec-once = blueman-applet
    #   exec-once = nm-applet --indicator
    #   exec-once = ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1
    #   exec-once = swayidle -w before-sleep 'gtklock -d'

    #   general {
    #     col.active_border = rgba(00fffafa)
    #   }
    #   monitor=eDP-1,preferred,auto,1

    #   input {
    #     kb_layout = es
    #     kb_variant =
    #     kb_model =
    #     kb_options =
    #     kb_rules =

    #     follow_mouse = 1

    #     touchpad {
    #         natural_scroll = true
    #     }

    #     sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
    #   }

    #   decoration {
    #     # See https://wiki.hyprland.org/Configuring/Variables/ for more

    #     rounding = 10

    #     drop_shadow = true
    #     shadow_range = 4
    #     shadow_render_power = 3
    #     col.shadow = rgba(1a1a1aee)

    #     blur {
    #       enabled = true
    #       size = 3
    #       passes = 1
    #     
    #       vibrancy = 0.1696
    #     }
    #   }

    #   

    #   animations {
    #     enabled = true

    #     # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

    #     bezier = myBezier, 0.05, 0.9, 0.1, 1.05

    #     animation = windows, 1, 7, myBezier
    #     animation = windowsOut, 1, 7, default, popin 80%
    #     animation = border, 1, 10, default
    #     animation = borderangle, 1, 8, default
    #     animation = fade, 1, 7, default
    #     animation = workspaces, 1, 6, default
    #   }

    #   $mod = SUPER
    #   bind = $mod, Return, exec, alacritty
    #   bind = $mod, D, exec, fuzzel
    #   bind = $mod SHIFT, Q, killactive,
    #   bind = $mod, F, fullscreen
    #   bind = $mod, E, exec, nautilus
    #   bind = , Print, exec, screenshot area
    #   bind = $mod, Print, exec, screenshot output
    #   bind = SHIFT, Print, exec, screenshot window
    #   bind = $mod SHIFT, N, exec, swaync-client -t -sw

    #   # Move focus with mod + arrow keys
    #   bind = $mod, left, movefocus, l
    #   bind = $mod, right, movefocus, r
    #   bind = $mod, up, movefocus, u
    #   bind = $mod, down, movefocus, d

    #   # Switch workspaces with mod + [0-9]
    #   bind = $mod, 1, workspace, 1
    #   bind = $mod, 2, workspace, 2
    #   bind = $mod, 3, workspace, 3
    #   bind = $mod, 4, workspace, 4
    #   bind = $mod, 5, workspace, 5
    #   bind = $mod, 6, workspace, 6
    #   bind = $mod, 7, workspace, 7
    #   bind = $mod, 8, workspace, 8
    #   bind = $mod, 9, workspace, 9
    #   bind = $mod, 0, workspace, 10

    #   # Move active window to a workspace with mod + SHIFT + [0-9]
    #   bind = $mod SHIFT, 1, movetoworkspace, 1
    #   bind = $mod SHIFT, 2, movetoworkspace, 2
    #   bind = $mod SHIFT, 3, movetoworkspace, 3
    #   bind = $mod SHIFT, 4, movetoworkspace, 4
    #   bind = $mod SHIFT, 5, movetoworkspace, 5
    #   bind = $mod SHIFT, 6, movetoworkspace, 6
    #   bind = $mod SHIFT, 7, movetoworkspace, 7
    #   bind = $mod SHIFT, 8, movetoworkspace, 8
    #   bind = $mod SHIFT, 9, movetoworkspace, 9
    #   bind = $mod SHIFT, 0, movetoworkspace, 10

    #   # Move/resize windows with mainMod + LMB/RMB and dragging
    #   bindm = $mod, mouse:272, movewindow
    #   bindm = $mod, mouse:273, resizewindow
    # '';
  };
}
