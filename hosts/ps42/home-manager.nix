{
  inputs,
  pkgs,
  lib,
  ...
}:
let
  internal_name = "Chimei Innolux Corporation 0x14D5 Unknown";
  home_name = "Samsung Electric Company SyncMaster H1AK500000";
  ultrawide_hdmi_name = "LG Electronics LG ULTRAWIDE 0x0003BECD";
  # vars = import ../sway/functions.nix { inherit pkgs lib; };
  lg_22inch_name = "LG Electronics 2D FHD LG TV 0x01010101";
  kodi = (
    pkgs.kodi-wayland.withPackages (
      kodiPackages: with kodiPackages; [
        netflix
        youtube
      ]
    )
  );
in
{

  custom = {
    wl = {
      enable = true;
      river.enable = true;
      waybar.enable = true;
      niri.enable = true;
    };
    desktop.enable = true;
    dev.enable = true;
  };
  home.packages = [
    pkgs.discord
    # kodi
  ];

  wayland.windowManager.sway = {
    config.workspaceOutputAssign = [
      {
        workspace = "1";
        output = [ "eDP-1" ];
      }
      {
        workspace = "2";
        output = [ "eDP-1" ];
      }
      {
        workspace = "3";
        output = [ "eDP-1" ];
      }
      {
        workspace = "4";
        output = [ "eDP-1" ];
      }
      {
        workspace = "5";
        output = [ "eDP-1" ];
      }
      {
        workspace = "6";
        output = [
          "HDMI-A-1"
          "eDP-1"
        ];
      }
      {
        workspace = "7";
        output = [
          "HDMI-A-1"
          "eDP-1"
        ];
      }
      {
        workspace = "8";
        output = [
          "HDMI-A-1"
          "eDP-1"
        ];
      }
      {
        workspace = "9";
        output = [
          "HDMI-A-1"
          "eDP-1"
        ];
      }
      {
        workspace = "10";
        output = [
          "HDMI-A-1"
          "eDP-1"
        ];
      }
    ];

  };
  services.kanshi = {
    enable = true;
    settings = [
      {
        profile.name = "laptop";
        profile.outputs = [
          {
            criteria = internal_name;
            status = "enable";
            scale = 1.0;
          }
        ];
      }
      {
        profile.name = "desk_lid_down";
        profile.outputs = [
          {
            criteria = ultrawide_hdmi_name;
            position = "0,0";
            mode = "2560x1080@100Hz";
            adaptiveSync = true;
            status = "enable";
          }
          {
            criteria = internal_name;
            status = "disable";
          }
        ];
      }

      {
        profile.name = "home";
        profile.outputs = [
          {
            criteria = home_name;
            status = "enable";
            position = "280,0";
          }
          {
            criteria = internal_name;
            position = "0,768";
            status = "enable";
          }
        ];
      }
      {
        profile.name = "home2";
        profile.outputs = [
          {
            criteria = lg_22inch_name;
            status = "enable";
            position = "0,0";
          }
          {
            criteria = internal_name;
            position = "0,1080";
            status = "enable";
          }
        ];
      }
      {
        profile.name = "desk_lid_down_2";
        profile.outputs = [
          {
            criteria = "Ancor Communications Inc ASUS VP228 J7LMTF119528";
            status = "enable";
            position = "0,0";
          }
          {
            criteria = internal_name;
            status = "disable";
          }
        ];
      }
    ];
  };

  home.stateVersion = "22.11";
}
