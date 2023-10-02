{ config, pkgs, lib, ... }:
let
  nixos-config = "~/projects/nixos-config";
in
{
  xdg.enable = true;

  #programs.git = {
  #  enable = true;
  #  userName = "Toomoch";
  #  userEmail = "vallsfustearnau@gmail.com";
  #};

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.starship.enable = true;

  programs.bash = {
    enable = true;
    bashrcExtra = ''
      eval "$(starship init bash)"
      function set_win_title(){
        echo -ne "\033]0; $PWD \007"
      }
      starship_precmd_user_func="set_win_title"
    '';
    profileExtra = ''
    '';
    sessionVariables = { };
    shellAliases = {
      ls = "ls --human-readable --color=auto -la";
      ip = "ip -c";
      gs = "git status";
      gd = "git diff";
      gl = "git log";
      gaa = "git add --all";
      ".." = "cd ..";
      lsperms = "stat --format '%a'";
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
  };

}
