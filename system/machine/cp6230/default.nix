{ inputs, config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../users/j.nix
  ];

  networking.hostName = "cp6230"; 

  environment.systemPackages = with pkgs; [

  ];

  common.enable = true;
  common.x86.enable = true;
  desktop.enable = true;
  desktop.kde.enable = true;
  desktop.flatpak.enable = true;

  # Enable VAAPI hardware acceleration
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      vaapiIntel
    ];
  };

  # Undervolt
  #services.undervolt = {
  #  enable = true;
  #  coreOffset = -70;
  #  uncoreOffset = -20;
  #  gpuOffset = -30;
  #  analogioOffset = -20;
  #};

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
