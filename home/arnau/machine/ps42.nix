{ inputs, config, pkgs, lib, ... }:
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
            mode = "2560x1080@99.943";
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
