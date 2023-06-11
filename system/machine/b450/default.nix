{ config, pkgs, lib, ... }:
{
  networking.hostName = "b450"; # Define your hostname.

  imports = [
    ./hardware-configuration.nix
    ../../users/arnau.nix
    ../../common.nix
    ../../gaming.nix
  ];

  # Enable VAAPI hardware acceleration
  programs.firefox = {
    enable = true;
    preferences = {
      "media.ffmpeg.vaapi.enabled" = true;
    };
  };

  desktop.enable = true;
  desktop.arctis9.enable = true;
  desktop.sway.enable = true;
  vm.podman.enable = true;
  vm.libvirtd.enable = true;

  # OpenRGB
  services.hardware.openrgb.enable = true;

  # Enable the IOMMU
  boot.kernelParams = [ "amd_iommu=on" ];

  # LTS Kernel
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_1;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}
