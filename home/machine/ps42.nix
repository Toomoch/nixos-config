{ inputs, pkgs, lib, ... }:
let
  internal_name = "Chimei Innolux Corporation 0x14D5 Unknown";
  home_name = "Samsung Electric Company SyncMaster H1AK500000";
  ultrawide_hdmi_name = "LG Electronics LG ULTRAWIDE 0x0003BECD";
  vars = import ../sway/functions.nix { inherit pkgs lib; };
in {
  imports = [
    ../default.nix
    ../desktop.nix
    ../sway
    ../personal.nix
    ../devtools.nix
    ../nvim.nix
    ../class.nix
    ../river.nix
  ];

  home.packages = [ pkgs.discord ];

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
        output = [ "HDMI-A-1" "eDP-1" ];
      }
      {
        workspace = "7";
        output = [ "HDMI-A-1" "eDP-1" ];
      }
      {
        workspace = "8";
        output = [ "HDMI-A-1" "eDP-1" ];
      }
      {
        workspace = "9";
        output = [ "HDMI-A-1" "eDP-1" ];
      }
      {
        workspace = "10";
        output = [ "HDMI-A-1" "eDP-1" ];
      }
    ];

  };
  services.kanshi = {
    enable = true;
    settings = [
      {
        profile.name = "laptop";
        profile.outputs = [{
          criteria = internal_name;
          status = "enable";
        }];
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
            criteria = vars.lg_22inch_name;
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
    ];
  };

  home.stateVersion = "22.11";
}
