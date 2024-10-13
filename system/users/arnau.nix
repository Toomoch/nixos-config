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
    shell = pkgs.bash;
  };
  programs.zsh.enable = true;

  security.pam.services.sudo.u2fAuth = true;
  security.pam.services.login.u2fAuth = true;
  security.pam.services.greetd.u2fAuth = true;
  security.pam.u2f = {
    enable = true;
    cue = true;
    origin = "pam://arnau";
    authFile = "${private}/secrets/plain/u2f_keys";
  };

  # pam_rssh
  security.pam.services.sudo.text = lib.mkDefault (lib.mkBefore ''
    auth sufficient ${pkgs.pam_rssh}/lib/libpam_rssh.so auth_key_file=/etc/ssh/authorized_keys.d/''${user}
  '');
  security.sudo.extraConfig = ''
    Defaults env_keep+=SSH_AUTH_SOCK
  '';

  age.secrets.passwordfile-arnau.rekeyFile = "${private}/secrets/age/password.age";
  nix.settings.trusted-users = [ "${user}" ];
}
