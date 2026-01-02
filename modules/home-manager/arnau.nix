{
  config,
  pkgs,
  lib,
  self,
  osConfig,
  ...
}:
let
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
    MANPAGER = "nvim +Man!";
  };

  xdg.enable = true;

  programs.git = {
    enable = false;
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
    };
    # inherit shellAliases;
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
