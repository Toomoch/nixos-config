{ config, pkgs, lib, inputs, private, secrets, ... }:
let
  user = "${secrets.hosts.${config.networking.hostName}.user}";
in
{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${user} = {
    isNormalUser = true;
    description = "Arnau";
    extraGroups = [ "networkmanager" "wheel" "adbusers" "libvirtd" "docker" "dialout" ];
    packages = with pkgs; [ ];

    hashedPasswordFile = config.age.secrets.passwordfile-arnau.path;
    openssh.authorizedKeys.keys = secrets.authlist config.networking.hostName;
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;

  # sudo sshAgentAuth
  security.pam.sshAgentAuth.enable = true;
  security.pam.services.sudo = { sshAgentAuth = true; u2fAuth = true; };
  security.pam.services.login.u2fAuth = true;
  security.pam.services.greetd.u2fAuth = true;
  security.pam.u2f = {
    enable = true;
    cue = true;
    origin = "pam://arnau";
    authFile = "${private}/secrets/plain/u2f_keys";
  };

  age.secrets.passwordfile-arnau.rekeyFile = "${private}/secrets/age/password.age";
  #security.pam.services.arnau.sshAgentAuth = true;
  # for unstable: (check https://github.com/NixOS/nixpkgs/issues/31611)
  # security.pam.sshAgentAuth.authorizedKeysFiles = lib.mkForce [ "/etc/ssh/authorized_keys.d/%u" ];
  nix.settings.trusted-users = [ "${user}" ];
}
