{ inputs, config, pkgs, lib, secrets, osConfig, private, ... }:
let
  vars = import ../sway/functions.nix { inherit pkgs lib; };
  internal_name = "Samsung Display Corp. 0x417B Unknown";
  workplace_name = "ASUSTek COMPUTER INC VG34VQEL1A S4LMDW002954";
  ultrawide_hdmi_name = "LG Electronics LG ULTRAWIDE 0x0003BECD";
  hostname = osConfig.networking.hostName;
in {
  imports = [
    "${private}/home/arnau/"
    ../default.nix
    ../desktop.nix
    ../sway
    ../nvim.nix
    ../devtools.nix
    ../river.nix
    inputs.nixvim.homeManagerModules.nixvim
  ];

  home.packages = with pkgs; [ glab uuu freerdp3 cmake pandoc bind ];

  home.username = lib.mkForce secrets.hosts.${secrets.work.hostName}.user;
  home.homeDirectory =
    lib.mkForce "/home/${secrets.hosts.${secrets.work.hostName}.user}";

  programs.nixvim.plugins.lsp.servers.ltex.settings.language =
    lib.mkForce "en-US";

  programs.git.lfs.enable = true;

  services.kanshi = {
    enable = true;
    settings = [
      {
        profile.name = "laptop";
        profile.outputs = [{
          criteria = internal_name;
          status = "enable";
          scale = 2.0;
        }];
      }
      {
        profile.name = "workspace";
        profile.outputs = [
          {
            criteria = workplace_name;
            mode = "3440x1440@75Hz";
            position = "1440,0";
            scale = 1.25;
            status = "enable";
          }
          {
            criteria = internal_name;
            position = "0,540";
            scale = 2.0;
            status = "enable";
          }
        ];
      }
    ];
  };

  home.stateVersion = "24.11";
}

