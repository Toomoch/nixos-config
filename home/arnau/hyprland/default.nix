{ inputs, config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [

  ];

  #
  imports = [
    ../sway/waybar.nix
  ];
  
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    extraConfig = ''
      exec-once = wpaperd
      exec-once = swaync
      exec-once = waybar
      exec-once = blueman-applet
      exec-once = nm-applet --indicator
      exec-once = ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1
      exec-once = swayidle -w before-sleep 'gtklock -d'

      general {
        col.active_border = rgba(00fffafa)
      }
      monitor=eDP-1,preferred,auto,1

      input {
        kb_layout = es
        kb_variant =
        kb_model =
        kb_options =
        kb_rules =

        follow_mouse = 1

        touchpad {
            natural_scroll = true
        }

        sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
      }

      decoration {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more

        rounding = 10

        drop_shadow = true
        shadow_range = 4
        shadow_render_power = 3
        col.shadow = rgba(1a1a1aee)

        blur = true
        blur_size = 3
        blur_passes = 1
        blur_new_optimizations = true
      }

      

      animations {
        enabled = true

        # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

        bezier = myBezier, 0.05, 0.9, 0.1, 1.05

        animation = windows, 1, 7, myBezier
        animation = windowsOut, 1, 7, default, popin 80%
        animation = border, 1, 10, default
        animation = borderangle, 1, 8, default
        animation = fade, 1, 7, default
        animation = workspaces, 1, 6, default
      }

      $mod = SUPER
      bind = $mod, Return, exec, alacritty
      bind = $mod, D, exec, fuzzel
      bind = $mod SHIFT, Q, killactive,
      bind = $mod, F, fullscreen
      bind = $mod, E, exec, nautilus
      bind = , Print, exec, screenshot area
      bind = $mod, Print, exec, screenshot output
      bind = SHIFT, Print, exec, screenshot window
      bind = $mod SHIFT, N, exec, swaync-client -t -sw

      # Move focus with mod + arrow keys
      bind = $mod, left, movefocus, l
      bind = $mod, right, movefocus, r
      bind = $mod, up, movefocus, u
      bind = $mod, down, movefocus, d

      # Switch workspaces with mod + [0-9]
      bind = $mod, 1, workspace, 1
      bind = $mod, 2, workspace, 2
      bind = $mod, 3, workspace, 3
      bind = $mod, 4, workspace, 4
      bind = $mod, 5, workspace, 5
      bind = $mod, 6, workspace, 6
      bind = $mod, 7, workspace, 7
      bind = $mod, 8, workspace, 8
      bind = $mod, 9, workspace, 9
      bind = $mod, 0, workspace, 10

      # Move active window to a workspace with mod + SHIFT + [0-9]
      bind = $mod SHIFT, 1, movetoworkspace, 1
      bind = $mod SHIFT, 2, movetoworkspace, 2
      bind = $mod SHIFT, 3, movetoworkspace, 3
      bind = $mod SHIFT, 4, movetoworkspace, 4
      bind = $mod SHIFT, 5, movetoworkspace, 5
      bind = $mod SHIFT, 6, movetoworkspace, 6
      bind = $mod SHIFT, 7, movetoworkspace, 7
      bind = $mod SHIFT, 8, movetoworkspace, 8
      bind = $mod SHIFT, 9, movetoworkspace, 9
      bind = $mod SHIFT, 0, movetoworkspace, 10

      # Move/resize windows with mainMod + LMB/RMB and dragging
      bindm = $mod, mouse:272, movewindow
      bindm = $mod, mouse:273, resizewindow
    '';
  };
}
