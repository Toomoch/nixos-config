{ inputs, config, lib, pkgs, ...}:
{

  cfg = config.homelab;
  serviceData = # If host is h81, use the ZFS array 
    if config.networking.hostName == "h81" then
      "/zstorage/data"
    else
      "/var/lib";
  
  commonextraOptions = [
    "--pull=always"
  ];
  timezone = "Europe/Madrid";
}
