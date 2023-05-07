{ config, pkgs, lib, ... }:
{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.arnau = {
    isNormalUser = true;
    description = "Arnau";
    extraGroups = [ "networkmanager" "wheel" "adbusers" "libvirtd"];
    packages = with pkgs; [ ];
    initialPassword = "12345678";
    passwordFile = "/etc/secrets/nixos/arnau-passwordFile";
  };
}
