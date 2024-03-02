{ inputs, config, pkgs, lib, ... }:
with import ../sway/functions.nix { inherit pkgs lib; }; 
let
  internal_name = "Chimei Innolux Corporation 0x14D5 Unknown";
  home_name = "Samsung Electric Company SyncMaster H1AK500000";
in
{
  imports = [
    ../default.nix
    ../desktop.nix
    ../sway
    ../personal.nix
    ../devtools.nix
    ../nvim.nix
    inputs.nixvim.homeManagerModules.nixvim
    #../hyprland
  ];

  home.packages = with pkgs; [

  ];

  services.kanshi = {
    enable = true;
    profiles = {
      laptop = {
        exec = monitor_workspace 1 10 internal_name;
        outputs = [
          {
            criteria = internal_name;
            status = "enable";
            
          }
        ];
      };

      desk_flat = {
        exec = monitor_workspace 1 5 internal_name ++ monitor_workspace 6 10 ultrawide_name;
        outputs = [
          {
            criteria = ultrawide_name;
            position = "0,0";
            mode = "2560x1080@100Hz";
            adaptiveSync = true;
            status = "enable";
          }
          {
            criteria = internal_name;
            position = "320,1080";
            status = "enable";
          }
        ];
      };

      home = {
        exec = monitor_workspace 1 5 internal_name ++ monitor_workspace 6 10 home_name;
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
    };
  };

  
  home.stateVersion = "22.11";
}
