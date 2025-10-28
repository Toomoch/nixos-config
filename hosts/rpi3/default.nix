{
  config,
  inputs,
  nixpkgs,
  pkgs,
  lib,
  secrets,
  private,
  ...
}:
let

in
{
  imports = [
    #./hardware-configuration.nix
    "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
    # Minimal stuff
    (nixpkgs.outPath + "/nixos/modules/profiles/minimal.nix")
  ];

  networking.hostName = "rpi3"; # Define your hostname.
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  environment.systemPackages = [
    pkgs.libraspberrypi
    pkgs.borgbackup
  ];

  custom.common.enable = true;
  custom.common.systemd-boot.enable = false;
  hardware.enableRedistributableFirmware = true;
  boot.supportedFilesystems.zfs = lib.mkForce false;
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
    openFirewall = true;
  };
  services.networkd-dispatcher = {
    enable = true;
    rules."50-tailscale" = {
      onState = [ "routable" ];
      script = ''
        #!${pkgs.runtimeShell}
        ${lib.getExe pkgs.ethtool} -K enu1u1 rx-udp-gro-forwarding on rx-gro-list off
      '';
    };
  };

  # Borg repos
  services.borgbackup.repos = {
    nextcloud = {
      path = "/external/borg/nextcloud";
      authorizedKeys = [
        "${builtins.readFile /${private}/secrets/ssh/id_ed25519.borgnextcloud.pub}"
      ];
    };
  };

  # Use the extlinux boot loader.
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  zramSwap.enable = true;

  #users.users.arnau.openssh.authorizedKeys.keyFiles = [
  #  "${private}/secrets/ssh/id_ed25519.borgnextcloud.pub"
  #];

  # USB storage
  boot.initrd.availableKernelModules = [ "usb_storage" ];
  fileSystems."/external" = {
    device = "/dev/disk/by-id/usb-WD_Elements_10B8_575833314539343830434630-0:0-part1";
    fsType = "ext4";
    options = [ "nofail" ];
  };

  networking.useDHCP = lib.mkDefault true;

  services.prometheus.exporters = {
    node = {
      enable = true;
      openFirewall = true;
    };
  };

  wirenix = {
    enable = true;
    configurer = "networkd"; # defaults to "static", could also be "networkd"
    keyProviders = ["agenix-rekey"]; # could also be ["agenix-rekey"] or ["acl" "agenix-rekey"]
  };

  # Pi specific stuff
  #boot = {
  #  kernelParams = [ "cma=4M" ];
  #  kernelPackages = pkgs.linuxPackages_rpi3;
  #};
  #hardware.deviceTree = {
  #  filter = "*2837-rpi-3-b*";
  #  overlays = [
  #    { name = "sdoverclock"; dtsFile = ./sdhost-overclock.dts; }
  #  ];
  #};
  #nixpkgs.overlays = [
  #  #dt_ao_overlay
  #  (final: super: {
  #    makeModulesClosure = x:
  #      super.makeModulesClosure (x // { allowMissing = true; });
  #  })
  #];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
