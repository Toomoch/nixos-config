{ inputs, config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../users/g.nix
    ../../users/arnau.nix
  ];

  networking.hostName = "l50"; 

  environment.systemPackages = with pkgs; [
    telegram-desktop
    onlyoffice-bin
    vlc
    libsForQt5.dragon
    gnome.gnome-boxes
  ];

  common.enable = true;
  common.x86.enable = true;
  desktop.enable = true;
  desktop.kde.enable = true;
  desktop.flatpak.enable = true;
  vm.libvirtd.enable = true;

  # Enable VAAPI hardware acceleration
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
    ];
  };

  # Undervolt
  services.undervolt = {
    enable = true;
    coreOffset = -50;
    gpuOffset = -10;
    uncoreOffset = 0;
    analogioOffset = 0;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
