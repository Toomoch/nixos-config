{ inputs, config, pkgs, lib, ... }:
let
  vars = import ../sway/functions.nix { inherit pkgs lib; };
  ftdi_id = "/dev/serial/by-id/usb-FTDI_TTL232R-3V3_FTA5I86L-if00-port0";
  imx6_id = "/dev/serial/by-id/usb-Silicon_Labs_CP2102_USB_to_UART_Bridge_Controller_0001-if00-port0";
  internal_name = "AU Optronics 0x408D Unknown";
  workplace_name = "Philips Consumer Electronics Company PHL 243V7 0x000033E1";
  ultrawide_hdmi_name = "LG Electronics LG ULTRAWIDE 0x0003BECD";
in
{
  imports = [
    "${inputs.private}/home/arnau/"
    ../default.nix
    ../arnau.nix
    ../desktop.nix
    ../sway
    ../nvim.nix
    ../devtools.nix
    inputs.nixvim.homeManagerModules.nixvim
  ];

  home.packages = with pkgs; [
    teams-for-linux
    glab
    uuu
    python311Packages.python-gitlab
    freerdp3
    cmake
    pandoc
  ];

  programs.git.lfs.enable = true;

  programs.bash.shellAliases = {
    tioftdi = "tio -b 115200 ${ftdi_id}";
    tioimx6 = "tio -b 115200 ${imx6_id}";
  };

  services.kanshi = {
    enable = true;
    profiles = {
      laptop = {
        exec = vars.monitor_workspace 1 10 internal_name;
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
      workplace = {
        exec = vars.monitor_workspace 1 5 internal_name ++ vars.monitor_workspace 6 10 workplace_name;
        outputs = [
          {
            criteria = workplace_name;
            position = "1920,0";
            mode = "1920x1080@75Hz";
            status = "enable";
          }
          {
            criteria = internal_name;
            position = "0,0";
            status = "enable";
          }
        ];
      };
    };
  };

  #wayland.windowManager.sway.config = {
  #  output = {
  #    "AU Optronics 0x408D Unknown" = {
  #      mode = "1920x1080@60Hz";
  #      pos = "0 1080";
  #    };
  #    "LG Electronics 2D FHD LG TV 0x00000101" = {
  #      mode = "1920x1080@60Hz";
  #      pos = "0 0";
  #    };
  #    "Samsung Electric Company SyncMaster H1AK500000" = {
  #      mode = "1360x768@60Hz";
  #      pos = "280 312";
  #    };
  #    "Philips Consumer Electronics Company PHL 243V7 0x000033E1" = {
  #      mode = "1920x1080@75Hz";
  #      pos = "1920 1080";
  #    };
  #  };
  #  workspaceOutputAssign = [
  #    {
  #      workspace = "1";
  #      output = "eDP-1";
  #    }
  #    {
  #      workspace = "2";
  #      output = "eDP-1";
  #    }
  #    {
  #      workspace = "3";
  #      output = "eDP-1";
  #    }
  #    {
  #      workspace = "4";
  #      output = "eDP-1";
  #    }
  #    {
  #      workspace = "5";
  #      output = [ "DP-1" "DP-3" ];
  #    }
  #    {
  #      workspace = "6";
  #      output = [ "DP-1" "DP-3" ];
  #    }
  #    {
  #      workspace = "7";
  #      output = [ "DP-1" "DP-3" ];
  #    }
  #    {
  #      workspace = "8";
  #      output = [ "DP-1" "DP-3" ];
  #    }
  #  ];
  #};

  home.stateVersion = "23.05";
}

