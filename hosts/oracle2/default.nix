{
  config,
  pkgs,
  lib,
  private,
  nixpkgs,
  secrets,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    # Minimal stuff
    (nixpkgs.outPath + "/nixos/modules/profiles/minimal.nix")
    # ./minecraft.nix
    ./metrics.nix
    ./disko.nix
  ];

  networking.hostName = "oracle2";

  # zfs required stuff
  services.zfs.autoScrub.enable = true;
  networking.hostId = "ba6f9367";
  boot.loader.systemd-boot.netbootxyz.enable = true;


  services.openssh.ports = [ secrets.hosts.oracle2.sshPort ];

  custom.common.enable = true;
  custom.common.systemd-boot.enable = true;
  custom.common.cloud.enable = true;
  custom.vm.podman.enable = true;
  security.polkit.enable = true;

  wirenix = {
    enable = true;
    configurer = "networkd"; # defaults to "static", could also be "networkd"
    keyProviders = [ "agenix-rekey" ]; # could also be ["agenix-rekey"] or ["acl" "agenix-rekey"]
  };
  networking.firewall.allowedUDPPorts = [ 51820 ];

  services.silverbullet = {
    enable = true;
  };

  # services.caddy.virtualHosts."silverbullet.${config.custom.homelab.primaryDomain}" = {
  #   extraConfig = ''
  #     reverse_proxy localhost:${config.services.silverbullet.listenPort}
  #   '';
  # };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
