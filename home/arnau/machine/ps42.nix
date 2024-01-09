{ inputs, config, pkgs, lib, ... }:
{
  imports = [
    ../default.nix
    ../desktop.nix
    ../sway
    ../personal.nix
    ../devtools.nix
    #../hyprland
  ];

  home.packages = with pkgs; [

  ];

  wayland.windowManager.sway.config = {
    output = {
      "Chimei Innolux Corporation 0x14D5 Unknown" = {
        mode = "1920x1080@60Hz";
        pos = "0 1080";
      };
      "LG Electronics 2D FHD LG TV 0x00000101" = {
        pos = "0 0";
      };
      "Samsung Electric Company SyncMaster H1AK500000" = {
        pos = "280 312";
      };
    };
    workspaceOutputAssign = [
      {
        workspace = "1";
        output = "eDP-1";
      }
      {
        workspace = "2";
        output = "eDP-1";
      }
      {
        workspace = "3";
        output = "eDP-1";
      }
      {
        workspace = "4";
        output = "eDP-1";
      }
      {
        workspace = "5";
        output = "HDMI-A-1";
      }
      {
        workspace = "6";
        output = "HDMI-A-1";
      }
      {
        workspace = "7";
        output = "HDMI-A-1";
      }
      {
        workspace = "8";
        output = "HDMI-A-1";
      }
    ];
  };

  home.stateVersion = "22.11";
}
