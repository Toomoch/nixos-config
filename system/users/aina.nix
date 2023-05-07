{ config, pkgs, lib, ... }:
{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.aina = {
    isNormalUser = true;
    description = "Aina";
    extraGroups = [ "networkmanager" "adbusers"];
    packages = with pkgs; [ ];
    initialPassword = "12345678";
    passwordFile = "/etc/secrets/nixos/aina-passwordFile";
  };
}
