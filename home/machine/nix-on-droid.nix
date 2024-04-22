{ config, lib, pkgs, ... }:
let
  dnshack = pkgs.callPackage (builtins.fetchTarball "https://github.com/ettom/dnshack/tarball/master") { };
  variables = {
    DNSHACK_RESOLVER_CMD = "${dnshack}/bin/dnshackresolver";
    LD_PRELOAD = "${dnshack}/lib/libdnshackbridge.so";
  };
  shellAliases = {
    "mosh" = "mosh --experimental-remote-ip=remote";
  };
in
{
  # Read the changelog before changing this value
  home.stateVersion = "23.11";
  imports = [
    ../default.nix
    ../personal.nix
  ];

  programs.bash.sessionVariables = variables;
  programs.zsh.sessionVariables = variables;


  programs.bash.shellAliases = shellAliases;
  programs.zsh.shellAliases = shellAliases;
  # insert home-manager config
}
