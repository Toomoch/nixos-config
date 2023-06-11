{ config, pkgs, lib, ... }:
with lib; let
  cfg = config.vm;
in
{
  options.vm = {
    podman.enable = mkEnableOption ("Wheter to enable podman");
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
          dockerCompat = true;
          # Required for containers under podman-compose to be able to talk to each other.
          defaultNetwork.settings.dns_enabled = true;
        };
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
