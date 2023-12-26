{ config, pkgs, lib, inputs, ... }:
{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.arnau = {
    isNormalUser = true;
    description = "Arnau";
    extraGroups = [ "networkmanager" "wheel" "adbusers" "libvirtd" "docker" "dialout" ];
    packages = with pkgs; [ ];
    initialHashedPassword = "$y$j9T$B3GNXEDtu.tLypNHqtugL1$0TLc8R/9W0PRyTz9XCS43gbj/Fig9r2GoWyxoVdNdZ.";
    openssh.authorizedKeys.keyFiles = [ 
      "${inputs.private}/secrets/keys.pub"
    ];
  };



  nix.settings.trusted-users = [ "arnau" ];
}
