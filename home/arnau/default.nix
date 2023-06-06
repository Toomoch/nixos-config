{ config, pkgs, lib, ... }:
let
  nixos-config = "~/projects/nixos-config";
in
{
  xdg.enable = true;

  programs.git = {
    enable = true;
    userName = "Toomoch";
    userEmail = "vallsfustearnau@gmail.com";
  };

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.starship.enable = true;

  programs.bash = {
    enable = true;
    bashrcExtra = ''
      eval "$(starship init bash)"
    '';
    profileExtra = ''
    '';
    sessionVariables = { };
    shellAliases = {
      ls = "ls --human-readable --color=auto -l";
      ip = "ip -c";
      gs = "git status";
      gd = "git diff";
      gl = "git log";
      gaa = "git add --all";
      ".." = "cd ..";
      upcdown = "rclone copy upc:/assig ~/assig/ --drive-acknowledge-abuse -P";
      upcup = "rclone copy ~/assig/ upc:/assig/ --drive-acknowledge-abuse -P";
      upcsync = "upcdown && upcup";
      upclink = "${config.home.homeDirectory}/scripts/upclink.sh";
      nrswitch = "cd ${nixos-config} && git add . && sudo nixos-rebuild switch --flake . && cd -";
      nrboot = "cd ${nixos-config} && git add . && sudo nixos-rebuild boot --flake . && cd -";
      nrtest = "cd ${nixos-config} && git add . && sudo nixos-rebuild test --flake . && cd -";
      nrbuild = "cd ${nixos-config} && git add . && sudo nixos-rebuild build --flake . && cd -";
      nu = "cd ${nixos-config} && git add . && sudo nix flake update && cd -";
      sshgen = "ssh-keygen -t ed25519 -C 'vallsfustearnau@gmail.com'";
    };

  };

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "ubuntu" = {
        hostname = "192.168.122.16";
        user = "alumne";
        port = 22;
        forwardX11 = true;
        forwardX11Trusted = true;
      };
    };
  };

}
