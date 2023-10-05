{ config, pkgs, lib, sops-nix, ... }:
{
  networking.hostName = "b450"; # Define your hostname.

  imports = [
    ./hardware-configuration.nix
    ../../users/arnau.nix
    ../../modules
  ];

  # Enable VAAPI hardware acceleration
  programs.firefox = {
    enable = true;
    preferences = {
      "media.ffmpeg.vaapi.enabled" = true;
    };
  };

  common.enable = true;
  common.x86.enable = true;
  desktop.enable = true;
  desktop.arctis9.enable = true;
  desktop.sway.enable = true;
  desktop.hyprland.enable = false;
  desktop.flatpak.enable = true;
  desktop.gaming.enable = true;
  desktop.gaming.g29.enable = true;
  vm.podman.enable = true;
  vm.libvirtd.enable = true;
  vm.docker.enable = true;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # OpenRGB
  services.hardware.openrgb.enable = true;

  # Enable the IOMMU
  boot.kernelParams = [ "amd_iommu=on" ];

  # Sops
  sops.defaultSopsFile = "/root/.sops/secrets/example.yaml";
  sops.validateSopsFiles = false;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.secrets."arnau_passwd" = {};
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
