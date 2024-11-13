let
  # MX150
  gpuIDs = [
    "10de:1d10" # Graphics
  ];
in
{ pkgs, lib, config, ... }: {
  options.vfio.enable = with lib;
    mkEnableOption "Configure the machine for VFIO";

  config =
    let cfg = config.vfio;
    in {
      boot = {
        initrd.kernelModules = [
          "vfio_pci"
          "vfio"
          "vfio_iommu_type1"
          "vfio_virqfd"

          "nouveau"
        ];

        kernelParams = [
          # enable IOMMU
          "intel_iommu=on"
        ] ++ lib.optional cfg.enable
          # isolate the GPU
          ("vfio-pci.ids=" + lib.concatStringsSep "," gpuIDs);
      };

      hardware.opengl.enable = true;
      virtualisation.spiceUSBRedirection.enable = true;
      systemd.tmpfiles.rules = [
        "f /dev/shm/looking-glass 0660 arnau libvirtd -"
      ];

      environment.systemPackages = with pkgs; [
        looking-glass-client
      ];
    };
}
