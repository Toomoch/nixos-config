{ config, pkgs, lib, ... }:
with lib; let
  cfg = config.vm;
in
{
  options.vm = {
    podman.enable = mkEnableOption ("Wheter to enable podman");
    docker.enable = mkEnableOption ("Wheter to enable Docker");
    libvirtd.enable = mkEnableOption ("Whether to enable libvirtd");
  };

  config = mkMerge [
    (mkIf cfg.podman.enable {
      environment.systemPackages = with pkgs; [
        podman-compose
        distrobox
      ];
      virtualisation = {
        podman = {
          enable = true;
          # Create a `docker` alias for podman, to use it as a drop-in replacement
          dockerCompat = false;
          # Required for containers under podman-compose to be able to talk to each other.
          defaultNetwork.settings.dns_enabled = true;
        };
        docker.enable = true;
      };
    })
    (mkIf cfg.docker.enable {
      environment.systemPackages = with pkgs; [
        docker-compose
      ];
      virtualisation = {
        docker.enable = true;
      };
    })
    (mkIf cfg.libvirtd.enable {
      environment.systemPackages = with pkgs; [
        win-virtio
      ];

      virtualisation = {
        # Enable libvirt
        libvirtd = {
          enable = true;
          qemu = {
            swtpm.enable = true;
            ovmf.packages = [
              pkgs.OVMFFull.fd
            ];
          };
        };
      };
    })
  ];


}
