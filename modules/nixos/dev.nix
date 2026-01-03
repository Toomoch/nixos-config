{
  self,
  pkgs,
  config,
  lib,
  ...
}:
let

  cfg = config.custom.dev;
  inherit (self.inputs) wrappers;

  tmuxsessionizer = pkgs.writeShellScriptBin "sessionizer" (
    builtins.readFile ../home-manager/dotfiles/tmux-sessionizer.sh
  );
  sopsPlugins = pkgs.sops.withAgePlugins (p: [ p.age-plugin-fido2-hmac ]);
  devPackages = with pkgs; [
    tmuxsessionizer
    libclang
    nixfmt-rfc-style
    shellcheck
    shfmt
    gnumake
    rage
    age-plugin-fido2-hmac
    sopsPlugins
    uv
    sshpass
    just
    tio
    tldr
    python313
    file
    self.packages.${pkgs.stdenv.hostPlatform.system}.nvim-mnw

    ripgrep
    gitWrapped
    git-lfs
  ];

  gitWrapped =
    (wrappers.wrapperModules.git.apply {
      inherit pkgs;

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

        user.name = "Toomoch";
        user.email = "vallsfustearnau@gmail.com";
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
    }).wrapper;

in
{

  options.custom.dev.enable = lib.mkEnableOption "Whther to enable arnau specific dev stuff";

  config = lib.mkIf cfg.enable {
    users.users.arnau.packages = devPackages;
    # dev
    programs.direnv.enable = true;
    programs.direnv.nix-direnv.enable = true;
    programs.tmux = {
      enable = true;
      clock24 = true;
      extraConfig = builtins.readFile ../home-manager/dotfiles/tmux.conf;
    };
    programs.starship.enable = true;
    programs.fzf.keybindings = true;
    environment.shellAliases = {
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
      vimdev = "${self.packages.${pkgs.stdenv.hostPlatform.system}.nvim-mnw.devMode}/bin/nvim";
    };
    environment.sessionVariables = {
      UV_PYTHON_DOWNLOADS = "never";
      UV_NO_MANAGED_PYTHON = "1";
      EDITOR = "nvim";
      MANPAGER = "nvim +Man!";
    };
    programs.ssh =
      let
        isValidHost = name: hostConfig: (hostConfig.config.custom.deployment.enable or false);

        mkHostBlock =
          name: hostConfig:
          let
            deploy = hostConfig.config.custom.deployment;
          in
          ''
            Host ${name}
              Hostname ${deploy.hostname}
              User ${deploy.user}
              Port ${toString deploy.port}
              ForwardAgent yes
          '';

        validHosts = lib.filterAttrs isValidHost self.nixosConfigurations;

        dynamicHostConfig = lib.concatStringsSep "\n" (lib.mapAttrsToList mkHostBlock validHosts);

        globalConfig = ''
          Host *
            SetEnv TERM="xterm-256color"
            AddKeysToAgent yes
            Compression no
            ForwardAgent no
            HashKnownHosts no
            ServerAliveCountMax 3
            ServerAliveInterval 0
            UserKnownHostsFile ~/.ssh/known_hosts
        '';
      in
      {

        extraConfig = ''
          ${dynamicHostConfig}

          ${globalConfig}
        '';
      };

  };
}
