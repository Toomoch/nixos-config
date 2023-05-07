{ config, pkgs, lib, ... }:
{
  specialisation.kde = {
    inheritParentConfig = false;
    configuration = {
      imports = [
        ./ps42.nix
        ./hardware-configuration.nix
        ../../users/aina.nix
        ../../default.nix
        ../../kde.nix
        ../../desktop.nix
      ];

      environment.systemPackages = with pkgs; [
        netbeans
        libsForQt5.kpat
        libsForQt5.kio-gdrive
      ];

      services.tlp.enable = lib.mkForce false;
      i18n.defaultLocale = lib.mkDefault "ca_ES.UTF-8";

    };
  };

  imports = [
    ./ps42.nix
    ./hardware-configuration.nix
    ../../users/arnau.nix
    ../../default.nix
    ../../desktop.nix
    ../../sway.nix
    ../../virtualisation.nix
  ];


}
