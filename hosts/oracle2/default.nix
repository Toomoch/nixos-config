{ config, pkgs, lib, private, nixpkgs, secrets, ... }:
{
  imports = [
    ./hardware-configuration.nix
    # Minimal stuff
    (nixpkgs.outPath + "/nixos/modules/profiles/minimal.nix")
  ];

  networking.hostName = "oracle2";

  services.openssh.ports = [ secrets.hosts.oracle2.sshPort ];

  custom.common.enable = true;
  custom.common.systemd-boot.enable = true;
  custom.common.cloud.enable = true;
  custom.vm.podman.enable = true;
  custom.vm.docker.enable  = true;
  security.polkit.enable = true;
  services.boinc.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
