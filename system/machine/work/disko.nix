{
  disko.devices = {
    disk = {
      vdb = {
        device = "/dev/disk/by-id/ata-CT500MX500SSD1_1822E14161FB";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              name = "ESP";
              type = "EF00";
              size = "500M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              name = "nixos";
              size = "-8G";
              content = {
                type = "filesystem";
                format = "btrfs";
                mountpoint = "/";
              };
            };
	    plainSwap = {
              size = "100%";
              content = {
                type = "swap";
                discardPolicy = "both";
                resumeDevice = true; # resume from hiberation from this device
              };
            };
          };
        };
      };
    };
  };
}
