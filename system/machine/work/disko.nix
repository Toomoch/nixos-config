{
  # checkout the example folder for how to configure different disko layouts
  disko.devices = {
    disk.sda = {
      device = "/dev/disk/by-id/nvme-INTEL_SSDPEKNW010T8_PHNH211502W31P0B";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            type = "EF00";
            size = "500M";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          swap = {
            type = "8200";
            size = "2G";
            content.type = "swap";
          };
          root = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
    };
  };
}
