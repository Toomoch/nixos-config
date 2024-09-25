{ inputs, config, pkgs, lib, ... }:
let
  vars = import ../sway/functions.nix { inherit pkgs lib; };
  DP_ultrawide = "LG Electronics LG ULTRAWIDE 0x0003BECD";
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
        exec = ''
          kanshi_assign_sway -m "${DP_ultrawide}" -b 1 -e 10
        '';
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
