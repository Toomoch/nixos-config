{ config, pkgs, lib, pkgs-unstable, flake-root, private, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../users/arnau.nix
    ./disko.nix
  ];

  nixpkgs.config.allowUnfree = true;

  networking.hostName = "h81"; # Define your hostname.

  virtualisation.vmVariant = {
    # following configuration is added only when building VM with build-vm
    virtualisation = {
      memorySize = 4096; # Use 2048MiB memory.
      cores = 4;
    };
  };

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.extraPools = [ "zstorage" ];
  boot.zfs.forceImportRoot = false;
  networking.hostId = "e0684fdb";

  age.secrets.secret1.rekeyFile = flake-root + "/private/secrets/age/test.age";

  common.enable = true;
  common.x86.enable = true;
  homelab.enable = true;
  homelab.homepage-dashboard.enable = true;
  homelab.homeassistant.enable = true;
  homelab.immich.enable = false;
  homelab.smb.enable = true;
  homelab.nextcloud.enable = true;
  homelab.grafana.enable = true;
  vm.podman.enable = true;
  vm.docker.enable  = true;
  vm.libvirtd.enable = true;
  security.polkit.enable = true;

  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  };
  hardware.opengl = { # hardware.graphics on unstable
    enable = true;
    extraPackages = with pkgs; [
      intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
