{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../users/arnau.nix
  ];

  nixpkgs.config.allowUnfree = true;

  networking.hostName = "oracle2";

  common.enable = true;
  common.x86.enable = true;
  vm.podman.enable = true;
  vm.docker.enable  = true;
  security.polkit.enable = true;
  services.boinc.enable = true;
  homelab.enablevps = false;
  
  boot.initrd.availableKernelModules = [
    "virtio_net"
    "virtio_pci"
    "virtio_mmio"
    "virtio_blk"
    "virtio_scsi"
  ];
  boot.initrd.kernelModules = [
    "virtio_balloon"
    "virtio_console"
    "virtio_rng"
  ];

  boot.kernelParams = [
    # Disable auditing
    "audit=0"
    # Do not generate NIC names based on PCIe addresses (e.g. enp1s0, useless for VPS)
    # Generate names based on orders (e.g. eth0)
    "net.ifnames=0"
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
