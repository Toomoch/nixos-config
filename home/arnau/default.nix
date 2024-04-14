{ config, pkgs, lib, inputs, ... }:
let
  nixos-config = "~/projects/nixos-config";
  sshpath = "${config.home.homeDirectory}/.ssh/id_ed25519";
  sshfix = "NIX_SSHOPTS=-i ${sshpath}";
  ip_path = "${inputs.private}/secrets/plain";
  tmux-sessionizer = pkgs.writeShellScriptBin "sessionizer" (builtins.readFile (./dotfiles/tmux-sessionizer.sh));
  domain = "${builtins.readFile "${inputs.private}/secrets/plain/domain"}";
  shellaliases = {
    ls = "ls --human-readable --color=auto -la";
    ip = "ip -c";
    ".." = "cd ..";
    lsperms = "stat --format '%a'";
    upcdown = "rclone copy upc:/assig ~/assig/ --drive-acknowledge-abuse -P";
    upcup = "rclone copy ~/assig/ upc:/assig/ --drive-acknowledge-abuse -P";
    upcsync = "upcdown && upcup";
    upclink = "${config.home.homeDirectory}/scripts/upclink.sh";
    nrswitch = "cd ${nixos-config} && git add . && nix flake archive && sudo '${sshfix}' nixos-rebuild switch --flake . && cd -";
    nrboot = "cd ${nixos-config} && git add . && nix flake archive && sudo '${sshfix}' nixos-rebuild boot --flake . && cd -";
    nrtest = "cd ${nixos-config} && git add . && nix flake archive && sudo '${sshfix}' nixos-rebuild test --flake . && cd -";
    nrbuild = "cd ${nixos-config} && git add . && nix flake archive && nixos-rebuild build --flake . && cd -";
    nu = "cd ${nixos-config} && git add . && nix flake update && cd -";
    sshgen = "ssh-keygen -t ed25519 -C $USER@$(hostname)";
    tiomenu = ''tio -b 115200 $(FZF_DEFAULT_COMMAND='find /dev/serial/by-id | tail -n +2 ' fzf --header="Pick a serial port")'';
  };
in
{
  home.username = "arnau";
  home.homeDirectory = lib.mkDefault "/home/arnau";
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    fzf
    tmux-sessionizer
  ];

  sops.age.sshKeyPaths = [ "${sshpath}" ];

  xdg.enable = true;

  programs.git = {
    enable = true;
    aliases = {
      co = "checkout";
      ci = "commit";
      a = "add";
      aa = "add --all";
      r = "restore";
      s = "status";
      l = "log --graph --all --decorate";
      d = "diff";
      ds = "diff --staged";
    };
  };

  programs.tmux = {
    enable = true;
    mouse = true;
    clock24 = true;
    extraConfig = builtins.readFile (./dotfiles/tmux.conf);
  };

  programs.zellij = {
    enable = true;
  };

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.starship.enable = true;

  programs.bash = {
    enable = true;
    bashrcExtra = ''
      ${builtins.readFile(./dotfiles/osc7.sh)}
      
      function set_win_title(){
        echo -ne "\033]0; $PWD \007"
      }
      starship_precmd_user_func="set_win_title"
    '';
    profileExtra = ''
    '';
    sessionVariables = { };
    shellAliases = shellaliases;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;
    shellAliases = shellaliases;
    initExtraFirst = ''
      zstyle ':completion:*' menu select
      zstyle ':completion::*' menu yes select
      zstyle ':completion::complete:*' use-cache 1
      zmodload zsh/complist
      _comp_options+=(globdots)		# Include hidden files.
    '';
  };

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "*" = {
        setEnv = {
          TERM = "xterm-256color";
        };
      };

      "oracle1" = {
        hostname = "${builtins.readFile (ip_path + "/oracle1_ip")}";
        extraOptions = { AddKeysToAgent = "yes"; };
        forwardAgent = true;
      };
      "oracle2" = {
        hostname = "${builtins.readFile (ip_path + "/oracle2_ip")}";
        extraOptions = { AddKeysToAgent = "yes"; };
        forwardAgent = true;
      };

      "h81" = {
        hostname = "h81.casa.lan";
        extraOptions = { AddKeysToAgent = "yes"; };
        forwardAgent = true;
      };
    };
    includes = [
      "config.d/*"
    ];
  };

  # Workaround for NixOS bruh moment https://github.com/nix-community/home-manager/issues/322
  home.file.".ssh/config" = {
    target = ".ssh/config_source";
    onChange = ''cat ~/.ssh/config_source > ~/.ssh/config && chmod 600 ~/.ssh/config'';
  };

}
