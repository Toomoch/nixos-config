{ inputs, config, pkgs, lib, ... }:
let
  vars = import ../sway/functions.nix { inherit pkgs lib; };
  DP_ultrawide = "LG Electronics LG ULTRAWIDE 0x0003BECD";
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
    inputs.nixvim.homeManagerModules.nixvim
  ];

  home.packages = with pkgs; [ vesktop ];
  services.kanshi = {
    enable = true;
    settings = [{
      profile = {
        name = "desk_flat";
        outputs = [{
          criteria = DP_ultrawide;
          position = "0,0";
          mode = "2560x1080@99.943Hz";
          adaptiveSync = false;
          status = "enable";
        }];
      };
    }];
  };

  home.stateVersion = "22.11";
}
