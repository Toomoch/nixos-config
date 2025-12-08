{
  config,
  pkgs,
  lib,
  inputs,
  self,
  osConfig,
  ...
}:
let
  tmux-sessionizer = pkgs.writeShellScriptBin "sessionizer" (
    builtins.readFile (./dotfiles/tmux-sessionizer.sh)
  );
  tmux-ssh = pkgs.writeShellScriptBin "sshmulti" (builtins.readFile (./dotfiles/tmux-ssh-ansible.sh));
  shellAliases = {
    ls = "ls --human-readable --color=auto -la";
    ip = "ip -c";
    ".." = "cd ..";
    lsperms = "stat --format '%a'";
    sshgen = "ssh-keygen -t ed25519 -C $USER@$(hostname)";
    tiomenu = ''tio -b 115200 $(FZF_DEFAULT_COMMAND='find /dev/serial/by-id | tail -n +2 ' fzf --header="Pick a serial port")'';
    agenix = "agenix --extra-flake-params \\?submodules=1";
    vim = "nvim";
    vimdiff = "nvim -d";
    aspm = "sudo lspci -vv | awk '/ASPM/{print $0}' RS= | grep --color -P '(^[a-z0-9:.]+|ASPM )'";
    grep = "grep --color=auto";
    vimdev = "${
      inputs.self.outputs.packages.${pkgs.stdenv.hostPlatform.system}.nvim-mnw.devMode
    }/bin/nvim";
  };
  isValidHost = name: hostConfig: (hostConfig.config.custom.deployment.enable or false);
in
{
  programs.home-manager.enable = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 15d";
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.packages = with pkgs; [
    fzf
    tmux-sessionizer
    deploy-rs
    iperf3
    borgbackup
    git-lfs
    tmux-ssh
    ripgrep
    bitbake-language-server
    inputs.self.outputs.packages.${pkgs.stdenv.hostPlatform.system}.nvim-mnw
  ];
  programs.fzf.enableZshIntegration = true;
  programs.fzf.enableBashIntegration = true;
  programs.fzf.enable = true;

  xdg.enable = true;

  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      alias = {
        co = "checkout";
        ci = "commit";
        a = "add";
        aa = "add --all";
        r = "restore";
        rs = "restore --staged";
        s = "status";
        l = "log --graph --all --decorate";
        d = "diff";
        ds = "diff --staged";
        home = "rev-parse --show-toplevel";
      };

      user.name = lib.mkDefault "Toomoch";
      user.email = lib.mkDefault "vallsfustearnau@gmail.com";
      color = {
        ui = true;
      };

      # https://git-scm.com/docs/git-rebase#Documentation/git-rebase.txt---autosquash
      rebase = {
        autosquash = true;
      };

      core = {
        editor = "nvim";
        # NOTE: you can invoke your editor with a different config
        #   editor = nvim -u /path/to/your/config

        # https://git-scm.com/docs/git-diff#Documentation/git-diff.txt---abbrevltngt
        abbrev = 12;
      };

      # List branches and tags from newest to oldest
      branch = {
        sort = "-committerdate";
      };
      tag = {
        sort = "-taggerdate";
      };

      column = {
        ui = "auto";
      };

      push = {
        # https://git-scm.com/docs/git-config#Documentation/git-config.txt-pushautoSetupRemote
        autoSetupRemote = true;
        # Push tags automatically
        followtags = true;
      };

      # https://wiki.smd.dev/en/GitGuidelines#conflict-presentation
      merge = {
        conflictstyle = "zdiff3";
        # https://git-scm.com/docs/git-config#Documentation/git-config.txt-mergelog
        log = true;
      };

      commit = {
        # verbose means that when you are writing the commit message, you will also see
        # the diff introduced by the commit.
        verbose = true;
        #   template = /path/to/your/commit/template.txt
      };

      diff = {
        #   algorithm = histogram
        # Colors moved text differently
        colorMoved = "plain";
        #   compactionHeuristic = true
      };

      # https://git-scm.com/book/en/v2/Git-Tools-Rerere
      # https://git-scm.com/docs/git-rerere
      rerere = {
        enabled = true;
        autoUpdate = true;
      };

      # Useful to link fixed commits in your commit descriptions
      # https://docs.kernel.org/process/submitting-patches.html#describe-your-changes
      pretty = {
        fixes = ''Fixes: %h ("%s")'';
      };

    };

  };

  programs.tmux = {
    enable = true;
    mouse = true;
    clock24 = true;
    extraConfig = builtins.readFile ./dotfiles/tmux.conf;
  };

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
    sessionVariables = {
      MANPAGER = "nvim +Man!";
    };
    inherit shellAliases;
  };

  programs.readline = {
    enable = true;
    variables = {
      editing-mode = "vi";
      show-mode-in-prompt = "on";
      vi-cmd-mode-string = ''\1\e[34;1m\2[N] \1\e[0m\2'';
      vi-ins-mode-string = ''\1\e[32;1m\2[I] \1\e[0m\2'';
      keyseq-timeout = "50";
    };
  };

  programs.zsh = {
    enable = false;
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
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        setEnv = {
          TERM = "xterm-256color";
        };
        extraOptions = {
          "AddKeysToAgent" = "yes";
          "ForwardAgent" = "no";
          "Compression" = "no";
          "ServerAliveInterval" = "0";
          "ServerAliveCountMax" = "3";
          "HashKnownHosts" = "no";
          "UserKnownHostsFile" = "~/.ssh/known_hosts";
        };

      };

      # ax3000t-1 = {
      #   hostname = secrets.hosts.ax3000t-1.dns;
      #   user = "root";
      # };
      # ax3000t-2 = {
      #   hostname = secrets.hosts.ax3000t-2.dns;
      #   user = "root";
      # };
      # r2100 = {
      #   hostname = secrets.hosts.r2100.dns;
      #   user = "root";
      # };
      # mi4a-1 = {
      #   hostname = secrets.hosts.mi4a-1.dns;
      #   user = "root";
      # };
      # mi4a-2 = {
      #   hostname = secrets.hosts.mi4a-2.dns;
      #   user = "root";
      # };
    }
    // lib.mapAttrs (name: hostConfig: {
      inherit (hostConfig.config.custom.deployment) hostname port user;
      forwardAgent = true;
    }) (lib.filterAttrs isValidHost self.nixosConfigurations);
    includes = [ "config.d/*" ];
  };

  # Workaround for NixOS bruh moment https://github.com/nix-community/home-manager/issues/322
  home.file.".ssh/config" = {
    target = ".ssh/config_source";
    onChange = "cat ~/.ssh/config_source > ~/.ssh/config && chmod 600 ~/.ssh/config";
  };

}
