{ config, pkgs, lib, inputs, ... }:
let
  secrets = "${inputs.private}/secrets";
in
{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${builtins.readFile (secrets + "/g_user")}" = {
    isNormalUser = true;
    description = "${builtins.readFile (secrets + "/g_desc")}";
    extraGroups = [ "networkmanager" "adbusers" ];
    packages = with pkgs; [ ];
    initialHashedPassword = "${builtins.readFile (secrets + "/jg_hash")}";
  };
}