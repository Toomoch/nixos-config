{ config, lib, pkgs, ... }:

# A temporary hack to `loginctl enable-linger $somebody` (for
# multiplexer sessions to last), until this one is unresolved:
# https://github.com/NixOS/nixpkgs/issues/3702
#
# Usage: `users.extraUsers.somebody.linger = true` or slt.

with lib;

let

  dataDir = "/var/lib/systemd/linger";

  lingeringUsers = map (u: u.name) (attrValues (flip filterAttrs config.users.users (n: u: u.linger)));

  lingeringUsersFile = builtins.toFile "lingering-users"
    (concatStrings (map (s: "${s}\n")
      (sort (a: b: a < b) lingeringUsers))); # this sorting is important for `comm` to work correctly

  updateLingering = ''
    if [ -e ${dataDir} ] ; then
      ls ${dataDir} | sort | comm -3 -1 ${lingeringUsersFile} - | xargs -r ${pkgs.systemd}/bin/loginctl disable-linger
      ls ${dataDir} | sort | comm -3 -2 ${lingeringUsersFile} - | xargs -r ${pkgs.systemd}/bin/loginctl  enable-linger
    fi
  '';

  userOptions = {
    options.linger = mkEnableOption "Lingering for the user";
  };

in

{
  options = {
    users.users = mkOption {
      type = with types; attrsOf (submodule userOptions);
    };
  };

  config = {
    system.activationScripts.update-lingering = stringAfter [ "users" ] updateLingering;
  };
}
