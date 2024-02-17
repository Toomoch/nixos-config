{ inputs, config, pkgs, lib, ... }:
let
  monitor_workspace = begin: end: monitor:
    let
      size = end - begin + 1;
    in
      lib.lists.imap1 (i: v: "${pkgs.sway}/bin/swaymsg workspace ${toString (i + begin - 1)}, move workspace to output \'\"${monitor}\"\'") (lib.lists.replicate size "");
in
{
  imports = [
    ../default.nix
    ../desktop.nix
    ../sway
    ../personal.nix
    ../devtools.nix
    ../nvim.nix
    #../hyprland
  ];

  home.packages = with pkgs; [

  ];

  services.kanshi = {
    enable = true;

    profiles = {
      laptop = {
        exec = monitor_workspace 1 10 "Chimei Innolux Corporation 0x14D5 Unknown";
        outputs = [
          {
            criteria = "Chimei Innolux Corporation 0x14D5 Unknown";
            status = "enable";
            
          }
        ];
      };
      desk_flat = {
        outputs = [
          {
            criteria = "LG Electronics LG ULTRAWIDE 0x0000BFCD";
            position = "0,0";
            mode = "2560x1080@100Hz";
            adaptiveSync = true;
            status = "enable";
          }
          {
            criteria = "Chimei Innolux Corporation 0x14D5 Unknown";
            status = "disable";
          }
        ];
      };
    };
  };

  
  home.stateVersion = "22.11";
}
