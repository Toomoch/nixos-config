{ inputs, config, lib, pkgs, ...}:
{

  domain = "${builtins.readFile "${inputs.private}/secrets/plain/domain"}";
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
