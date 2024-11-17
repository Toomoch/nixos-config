{ pkgs, lib, config, ... }:
let
  # MX150
  gpuIDs = [
    "10de:1d10" # Graphics
  ];
  cfg = config.vfio;
in {
  options.vfio.enable = with lib;
    mkEnableOption "Configure the machine for VFIO";

  config = lib.mkIf (cfg.enable && pkgs.system == "x86_64-linux") {
    boot = {
      initrd.kernelModules = [
        "vfio_pci"
        "vfio"
        "vfio_iommu_type1"

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
    systemd.tmpfiles.rules =
      [ "f /dev/shm/looking-glass 0660 arnau libvirtd -" ];

    environment.systemPackages = [ pkgs.looking-glass-client ];
  };
}
