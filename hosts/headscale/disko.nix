{
  disko.devices = {
    disk = {
      root = {
        type = "disk";
        device = "/dev/sda";
        imageSize = "10G";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              end = "-2G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
            encryptedSwap = {
              size = "100%";
              content = {
                type = "swap";
                randomEncryption = true;
              };
            };
          };
        };
      };
    };
  };
}
