{ config, inputs, nixpkgs, pkgs, lib, secrets, private, ... }:
let
  dt_ao_overlay = _final: prev: {
    deviceTree = prev.deviceTree // {
      applyOverlays = _final.callPackage ./apply-overlays-dtmerge.nix { };
    };
  };
in
{
  imports = [
    #./hardware-configuration.nix
    ../../users/arnau.nix
    "${private}/system/rpi3-wg.nix"
    "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"

    (nixpkgs.outPath + "/nixos/modules/profiles/minimal.nix")
  ];
  environment.noXlibs = lib.mkForce false;

  networking.hostName = "rpi3"; # Define your hostname.

  environment.systemPackages = [
    pkgs.libraspberrypi
    pkgs.borgbackup
  ];

  common.enable = true;
  hardware.enableRedistributableFirmware = true;
  boot.supportedFilesystems.zfs = lib.mkForce false;
  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  boot.initrd.availableKernelModules = [ "usb_storage" ];

  users.users.arnau.openssh.authorizedKeys.keyFiles = [
    "${private}/secrets/ssh/id_ed25519.borgnextcloud.pub"
  ];

  fileSystems."/external" = {
    device = "/dev/disk/by-id/usb-WD_Elements_10B8_575833314539343830434630-0:0-part1";
    fsType = "ext4";
    options = [ "nofail" ];
  };

  boot.kernelParams = [ "cma=4M" ];
  networking.useDHCP = lib.mkDefault true;

  boot = {
    kernelPackages = pkgs.linuxPackages_rpi3;
  };

  hardware.deviceTree = {
    filter = "*2837-rpi-3-b*";
    overlays = [
      { name = "sdoverclock"; dtsFile = ./sdhost-overclock.dts; }
    ];
  };
  nixpkgs.overlays = [
    #dt_ao_overlay
    (final: super: {
      makeModulesClosure = x:
        super.makeModulesClosure (x // { allowMissing = true; });
    })
  ];
  zramSwap.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
