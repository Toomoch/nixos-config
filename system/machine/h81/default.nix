{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../common.nix
    ../../users/arnau.nix
    ../../homelab.nix
  ];

  networking.hostName = "h81"; # Define your hostname.

  virtualisation.vmVariant = {
    # following configuration is added only when building VM with build-vm
    virtualisation = {
      memorySize = 4096; # Use 2048MiB memory.
      cores = 4;
    };
  };

  vm.podman.enable = true;
  vm.libvirtd.enable = true;
  security.polkit.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
