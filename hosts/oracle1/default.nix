{ config, pkgs, lib, nixpkgs, secrets, ... }:
{
  imports = [
    ./hardware-configuration.nix
    # Minimal stuff
    (nixpkgs.outPath + "/nixos/modules/profiles/minimal.nix")
    ./disko.nix
  ];

  networking.hostName = "oracle1";

  services.openssh.ports = [ secrets.hosts.oracle1.sshPort ];

  custom.common.enable = true;
  custom.common.cloud.enable = true;
  custom.vm.podman.enable = true;
  custom.vm.docker.enable = false;
  security.polkit.enable = true;
  custom.homelab.enablevps = false;

  wirenix = {
    enable = true;
    configurer = "networkd"; # defaults to "static", could also be "networkd"
    keyProviders = ["agenix-rekey"]; # could also be ["agenix-rekey"] or ["acl" "agenix-rekey"]
  };
  networking.firewall.allowedUDPPorts = [ 51820 ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
