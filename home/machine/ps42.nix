{ inputs, pkgs, lib, ... }:
let
  internal_name = "Chimei Innolux Corporation 0x14D5 Unknown";
  home_name = "Samsung Electric Company SyncMaster H1AK500000";
  ultrawide_hdmi_name = "LG Electronics LG ULTRAWIDE 0x0003BECD";
  vars = import ../sway/functions.nix { inherit pkgs lib; };
in
{
  imports = [
    ../default.nix
    ../arnau.nix
    ../desktop.nix
    ../sway
    ../personal.nix
    ../devtools.nix
    ../nvim.nix
    inputs.nixvim.homeManagerModules.nixvim
    #../hyprland
  ];

  home.packages = [

  ];

  #yambar = {
  #  enable = true;
  #  battery = "BAT0";
  #  ethernet = "enp1s1";
  #};

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
    profiles = {
      laptop = {
        exec = ''
          kanshi_assign_sway -m "${internal_name}" -b 1 -e 10
        '';
        outputs = [
          {
            criteria = internal_name;
            status = "enable";
          }
        ];
      };

      desk_lid_down = {
        exec = ''
          kanshi_assign_sway -m "${ultrawide_hdmi_name}" -b 1 -e 10
        '';
        outputs = [
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
      };

      home = {
        exec = vars.monitor_workspace 1 5 internal_name ++ vars.monitor_workspace 6 10 home_name;
        outputs = [
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
      };
      home2 = {
        exec = vars.monitor_workspace 1 5 internal_name ++ vars.monitor_workspace 6 10 vars.lg_22inch_name;
        outputs = [
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
      };
    };
  };


  home.stateVersion = "22.11";
}
