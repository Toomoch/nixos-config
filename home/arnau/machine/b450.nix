{ inputs, config, pkgs, lib, ... }:
with import ../sway/functions.nix { inherit pkgs lib; }; 
let
  DP_ultrawide = "LG Electronics LG ULTRAWIDE 0x0000BFCD";
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
  ];

  home.packages = with pkgs; [
    discord-screenaudio
  ];  
  services.kanshi = {
    enable = true;
    profiles = {
      desk_flat = {
        exec = monitor_workspace 1 10 DP_ultrawide;
        outputs = [
          {
            criteria = DP_ultrawide;
            position = "0,0";
            mode = "2560x1080@99.943Hz";
            adaptiveSync = true;
            status = "enable";
          } 
        ];
      };
    };
  };

  home.stateVersion = "22.11";
}
