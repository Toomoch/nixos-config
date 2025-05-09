{ config, pkgs, lib, inputs, secrets, ... }:
let
  nixos-config = "~/projects/nixos-config";
  sshpath = "${config.home.homeDirectory}/.ssh/id_ed25519";
  sshfix = "NIX_SSHOPTS=-i ${sshpath}";
  tmux-sessionizer = pkgs.writeShellScriptBin "sessionizer"
    (builtins.readFile (./dotfiles/tmux-sessionizer.sh));
  tmux-ssh = pkgs.writeShellScriptBin "sshmulti"
    (builtins.readFile (./dotfiles/tmux-ssh-ansible.sh));
  shellAliases = {
    ls = "ls --human-readable --color=auto -la";
    ip = "ip -c";
    ".." = "cd ..";
    lsperms = "stat --format '%a'";
    upcdown = "rclone copy upc:/assig ~/assig/ --drive-acknowledge-abuse -P";
    upcup = "rclone copy ~/assig/ upc:/assig/ --drive-acknowledge-abuse -P";
    upcsync = "upcdown && upcup";
    upclink = "${config.home.homeDirectory}/scripts/upclink.sh";
    nrswitch =
      "cd ${nixos-config} && git add . && nix flake archive && sudo '${sshfix}' nixos-rebuild switch --flake . && cd -";
    nrboot =
      "cd ${nixos-config} && git add . && nix flake archive && sudo '${sshfix}' nixos-rebuild boot --flake . && cd -";
    nrtest =
      "cd ${nixos-config} && git add . && nix flake archive && sudo '${sshfix}' nixos-rebuild test --flake . && cd -";
    nrbuild =
      "cd ${nixos-config} && git add . && nix flake archive && nixos-rebuild build --flake . && cd -";
    nu = "cd ${nixos-config} && git add . && nix flake update && cd -";
    sshgen = "ssh-keygen -t ed25519 -C $USER@$(hostname)";
    tiomenu = ''
      tio -b 115200 $(FZF_DEFAULT_COMMAND='find /dev/serial/by-id | tail -n +2 ' fzf --header="Pick a serial port")'';
    agenix = "agenix --extra-flake-params \\?submodules=1";
  };
in {
  programs.home-manager.enable = true;

  nix.gc = {
    automatic = true;
    frequency = "weekly";
    options = "--delete-older-than 15d";
  };

  home.packages = with pkgs; [
    fzf
    tmux-sessionizer
    deploy-rs
    iperf3
    borgbackup
    git-lfs
    tmux-ssh
  ];
  programs.fzf.enableZshIntegration = true;
  programs.fzf.enableBashIntegration = true;
  programs.fzf.enable = true;

  #sops.age.sshKeyPaths = [ "${sshpath}" ];

  xdg.enable = true;

  programs.git = {
    enable = true;
    lfs.enable = true;
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
    extraConfig = builtins.readFile ./dotfiles/tmux.conf;
  };

  programs.zellij = { enable = true; };

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.starship.enable = true;

  programs.bash = {
    enable = true;
    bashrcExtra = ''
      ${builtins.readFile ./dotfiles/osc7.sh}

      function set_win_title(){
        echo -ne "\033]0; $PWD \007"
      }
      starship_precmd_user_func="set_win_title"
    '';
    profileExtra = "";
    sessionVariables = { MANPAGER = "nvim +Man!";};
    inherit shellAliases;
  };

  programs.readline = {
    enable = true;
    variables = {
      editing-mode = "vi";
      show-mode-in-prompt = "on";
      vi-cmd-mode-string = ''\1\e[34;1m\2(cmd) \1\e[0m\2'';
      vi-ins-mode-string = '''';
      keyseq-timeout = "50";
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    inherit shellAliases;
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
        setEnv = { TERM = "xterm-256color"; };
        extraOptions = { AddKeysToAgent = "yes"; };
      };

      "oracle1" = {
        hostname = secrets.hosts.oracle1.dns;
        forwardAgent = true;
        port = secrets.hosts.oracle1.sshPort;
      };
      "oracle2" = {
        hostname = secrets.hosts.oracle2.dns;
        forwardAgent = true;
        port = secrets.hosts.oracle2.sshPort;
      };

      "h81" = {
        hostname = secrets.hosts.h81.dns;
        forwardAgent = true;
      };

      "rpi3" = {
        hostname = secrets.hosts.rpi3.dns;
        forwardAgent = true;
      };

      ax3000t-1 = {
        hostname = secrets.hosts.ax3000t-1.dns;
        user = "root";
      };
      ax3000t-2 = {
        hostname = secrets.hosts.ax3000t-2.dns;
        user = "root";
      };
      r2100 = {
        hostname = secrets.hosts.r2100.dns;
        user = "root";
      };
      mi4a-1 = {
        hostname = secrets.hosts.mi4a-1.dns;
        user = "root";
      };
      mi4a-2 = {
        hostname = secrets.hosts.mi4a-2.dns;
        user = "root";
      };
    };
    includes = [ "config.d/*" ];
  };

  # Workaround for NixOS bruh moment https://github.com/nix-community/home-manager/issues/322
  home.file.".ssh/config" = {
    target = ".ssh/config_source";
    onChange =
      "cat ~/.ssh/config_source > ~/.ssh/config && chmod 600 ~/.ssh/config";
  };

}
