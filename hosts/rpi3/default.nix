{
  config,
  inputs,
  nixpkgs,
  pkgs,
  lib,
  secrets,
  private,
  self,
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
    openFirewall = true;
    enable = true;
    extraUpFlags = [
      "--accept-dns=false"
      "--accept-routes=true"
      "--login-server=${self.nixosConfigurations.potato.config.services.headscale.settings.server_url}"
    ];
    authKeyFile = config.age.secrets.tailscale.path;
    # authKeyParameters = {
    #   preauthorized = true;
    #   # baseURL = config.services.headscale.settings.server_url;
    # };
    useRoutingFeatures = "both";
  };
  services.networkd-dispatcher = {
    enable = true;
    rules."50-tailscale" = {
      onState = [ "routable" ];
      script = ''
        #!${pkgs.runtimeShell}
        DEV="$(${pkgs.iproute2}/bin/ip --json route show default | ${lib.getExe pkgs.jq} .[0].dev -r)"
        ${lib.getExe pkgs.ethtool} -K "$DEV" rx-udp-gro-forwarding on rx-gro-list off
      '';
    };
  };

  # Use the extlinux boot loader.
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  zramSwap.enable = true;

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
    keyProviders = [ "agenix-rekey" ]; # could also be ["agenix-rekey"] or ["acl" "agenix-rekey"]
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

  # Disable stub resolver to not conflict with coredns
  services.resolved.extraConfig = ''
    DNSStubListener=no
  '';

  services.coredns = {
    enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
