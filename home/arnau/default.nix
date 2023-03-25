{ config, pkgs, lib, ... }:
{

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };


  programs.git = {
    enable = true;
    userName = "Toomoch";
    userEmail = "vallsfustearnau@gmail.com";
  };


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
      nr = "cd ~/config && git add . && sudo nixos-rebuild switch --flake . && cd -";
      nu = "cd ~/config && git add . && sudo nix flake update && sudo nixos-rebuild switch --flake . && cd -";
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





  home.stateVersion = "22.11";
}
