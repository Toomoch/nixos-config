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
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;

  security.pam.enableSSHAgentAuth = true;
  security.pam.services.sudo.sshAgentAuth = true;
  services.openssh.authorizedKeysFiles = lib.mkForce [ "/etc/ssh/authorized_keys.d/%u" ];
  security.pam.services.arnau.sshAgentAuth = true;
  # for unstable: (check https://github.com/NixOS/nixpkgs/issues/31611)
  # security.pam.sshAgentAuth.authorizedKeysFiles = lib.mkForce [ "/etc/ssh/authorized_keys.d/%u" ];
  nix.settings.trusted-users = [ "arnau" ];
}
