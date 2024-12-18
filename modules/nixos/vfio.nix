{ pkgs, lib, config, secrets, ... }:
let
  # MX150
  gpuIDs = [
    "10de:1d10" # Graphics
  ];
  user = "${secrets.hosts.${config.networking.hostName}.user}";
  cfg = config.vfio;
in {
  options = {
    vfio.enable = with lib; mkEnableOption "Configure the machine for VFIO";

    vfio.gpuIDs =
      lib.mkOption { type = with lib.types; types.listOf types.str; };
    vfio.devices = lib.mkOption {
      type = with lib; types.listOf (types.strMatching "[0-9a-f]{4}:[0-9a-f]{4}");
      default = [ ];
      example = [ "10de:1b80" "10de:10f0" ];
      description = "PCI IDs of devices to bind to vfio-pci";
    };
  };

  config = lib.mkIf (cfg.enable && pkgs.system == "x86_64-linux") {
    boot = {
      initrd.kernelModules = [
        "vfio_pci"
        "vfio"
        "vfio_iommu_type1"

      ];

      kernelParams = [
      ] ++ lib.optional cfg.enable
        # isolate the GPU
        ("vfio-pci.ids=" + builtins.concatStringsSep "," cfg.devices);
    };

    hardware.graphics.enable = true;
    virtualisation.spiceUSBRedirection.enable = true;
    systemd.tmpfiles.rules =
      [ "f /dev/shm/looking-glass 0660 ${user} libvirtd -" ];

    environment.systemPackages = [ pkgs.looking-glass-client ];
  };
}
