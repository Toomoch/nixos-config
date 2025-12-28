{
  config,
  pkgs,
  lib,
  self,
  ...
}:
{
  options.custom.desktop = {
    enable = lib.mkEnableOption "Whether to enable desktop stuff";
  };
  config = lib.mkIf config.custom.desktop.enable {
    home.packages = with pkgs; [
      #desktop apps
      gnome-disk-utility
      pavucontrol
      gnome-calculator
      onlyoffice-desktopeditors
      scrcpy
      virt-manager
      gnome-network-displays
      imhex
      (ungoogled-chromium.override {
        commandLineArgs = [ "--enable-features=TouchpadOverscrollHistoryNavigation" ];
        enableWideVine = true;
      })
      resources
      krita
      localsend
      # (nerdfonts.override { fonts = [ "Noto" ]; })
      masterpdfeditor4
      networkmanager_dmenu
      wireshark
      numbat
    ];

    fonts = {
      fontconfig = {
        enable = true;
        defaultFonts = {
          monospace = [ "Iosevka Nerd Font Mono" ];
          sansSerif = [ "Rubik" ];
        };
      };
    };

    home.sessionVariables = {
      TERMINAL = "alacritty --class xdgterminal";
    };

    home.file."${config.xdg.userDirs.pictures}/wallpapers/" = {
      source = ./wallpapers;
      recursive = true;
    };

    services.tailscale-systray.enable = true;

    systemd.user.sockets.ssh-tunnel-proxy = {
      Unit.Description = "Socket-activation for SSH-tunnel";
      Socket.ListenStream = [
        "127.0.0.1:3000"
        "[::1]:3000"
      ];
      Install.WantedBy = [ "sockets.target" ];
    };
    systemd.user.services =
      let
        silverbulletPort = toString self.nixosConfigurations.ampere.config.services.silverbullet.listenPort;
        inherit (self.nixosConfigurations.ampere.config.custom.deployment) port user hostname;
        remoteHost = "${user}@${hostname} -p ${toString port}";
      in
      {
        ssh-tunnel = {
          Unit = {
            Description = "Tunnel to SSH server";
            ## Stop-when-idle is controlled by `--exit-idle-time=` in proxy.service
            #  (from `man systemd-socket-proxyd`)
            StopWhenUnneeded = true;
          };
          Service = {
            Type = "notify";
            NotifyAccess = "all";
            ## Prefixed with `-` not to mark service as failed on net-fails;
            #  will be restarted on-demand by socket-activation.
            ExecStart = ''-${pkgs.openssh}/bin/ssh -kaxNT  -o ExitOnForwardFailure=yes -o ControlMaster=no -o StreamLocalBindUnlink=yes -o PermitLocalCommand=yes -o LocalCommand="systemd-notify --ready" ${remoteHost} -L ''${XDG_RUNTIME_DIR}/ssh-tunnel-proxy:localhost:${silverbulletPort}'';
          };
        };
        ssh-tunnel-proxy = {
          Unit = {
            Description = "Socket-activation proxy for SSH tunnel";

            ## Stop also when stopped listening for socket-activation.
            ## Stop also when ssh-tunnel stops/breaks
            #  (otherwise, could not restart).
            BindsTo = [
              "ssh-tunnel-proxy.socket"
              "ssh-tunnel.service"
            ];
            After = [
              "ssh-tunnel-proxy.socket"
              "ssh-tunnel.service"
            ];
          };

          Service = {
            ExecStart = ''${pkgs.systemd}/lib/systemd/systemd-socket-proxyd --exit-idle-time=500s ''${XDG_RUNTIME_DIR}/ssh-tunnel-proxy'';
          };
        };
      };

    xdg = {
      enable = true;
      userDirs = {
        enable = true;
        createDirectories = true;
      };
      # We force the override so we workaround the error below:
      #   Existing file '/.../.config/mimeapps.list' is in the way of
      #   '/nix/store/...-home-manager-files/.config/mimeapps.list'
      # Issue: https://github.com/nix-community/home-manager/issues/1213
      configFile."mimeapps.list".force = true;
      mimeApps = {
        enable = true;
        defaultApplications = {
          "application/pdf" = "firefox.desktop";
          "inode/directory" = "thunar.desktop";
          "application/zip" = "org.gnome.FileRoller.desktop";
          "text/html" = [ "firefox.desktop" ];
          "x-scheme-handler/http" = [ "firefox.desktop" ];
          "x-scheme-handler/https" = [ "firefox.desktop" ];
          "x-scheme-handler/about" = [ "firefox.desktop" ];
          "x-scheme-handler/unknown" = [ "firefox.desktop" ];
          "video/x-matroska" = "mpv.desktop";
          "image/png" = "firefox.desktop";
          "x-scheme-handler/terminal" = "Alacritty.desktop";
        };
        associations.added = {
          "image/png" = "firefox.desktop";
          "video/x-matroska" = "mpv.desktop";
          "application/pdf" = "firefox.desktop";
          "x-scheme-handler/terminal" = "Alacritty.desktop";
        };
      };

    };

    programs.alacritty = {
      enable = true;
      settings = {
        window.opacity = 1;
        font = {
          normal = {
            family = "monospace";
            style = "Regular";
          };
          size = 13;
        };
      };
    };

    programs.java = {
      enable = true;
      package = pkgs.jdk11;
    };

    programs.foot = {
      enable = true;
      settings = {
        main = {
          font = "monospace:size=12";
          dpi-aware = "yes";
        };
        colors = {
          background = "242424";
          foreground = "ffffff";
        };
      };
    };

    programs.vscode = {
      enable = true;
      package = pkgs.vscode;

      profiles.default.userSettings = {
        editor = {
          fontFamily = "monospace, 'Font Awesome 6 Free','Font Awesome 6 Brands','Font Awesome 6 Free Solid'";
          fontLigatures = true;
        };

        window.titleBarStyle = "custom";

        workbench = {
          iconTheme = "material-icon-theme";
          productIconTheme = "Default";
          colorTheme = "Adwaita Dark";
        };

        files.autoSave = "afterDelay";

        redhat.telemetry.enabled = false;

        clangd.fallbackFlags = [ "-I\${workspaceFolder}/include" ];

        update.mode = "none";
        nix.enableLanguageServer = true;
        nix.serverPath = "nixd";
        nix.serverSettings.nixd = {
          formatting = {
            command = [ "nixpkgs-fmt" ];
          };
          options = {
            enable = true;
            target = {
              installable = ".#nixosConfigurations.ps42.options";
            };
          };
        };
      };
    };

    #home.activation.boforeCheckLinkTargets = {
    #    after = [];
    #    before = [ "checkLinkTargets" ];
    #    data = ''
    #      userDir=/arnau/grmpf/.config/VSCodium/User
    #      rm -rf $userDir/settings.json
    #    '';
    #  };
    #
    #  home.activation.afterWriteBoundary = {
    #    after = [ "writeBoundary" ];
    #    before = [];
    #    data = ''
    #      userDir=/home/arnau/.config/VSCodium/User
    #      rm -rf $userDir/settings.json
    #      cat \
    #        ${(pkgs.formats.json {}).generate "blabla"
    #          config.programs.vscode.userSettings} \
    #        > $userDir/settings.json
    #    '';
    #  };

    xdg.configFile."networkmanager-dmenu/config.ini".text = lib.generators.toINI { } {
      dmenu = {
        dmenu_command = ''${lib.getExe pkgs.fuzzel} --dmenu --no-exit-on-keyboard-focus-loss -b 000000FF --font="monospace:size=20"'';
      };
      editor = {
        terminal = "alacritty";
      };
    };

    programs.mpv = {
      enable = true;
      config = {
        hwdec = "auto";
      };
    };

    home.pointerCursor = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 24;
      x11 = {
        enable = true;
        defaultCursor = "Adwaita";
      };
      gtk.enable = true;
    };

    gtk = {
      enable = true;
      theme = {
        name = "adw-gtk3-dark";
        package = pkgs.adw-gtk3;
      };
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
      cursorTheme = {
        name = "Adwaita";
        package = pkgs.adwaita-icon-theme;
      };
      font = {
        name = "sans";
        # package = pkgs.rubik;
        size = 11;
      };
      # gtk3.extraConfig = {
      #   gtk-application-prefer-dark-theme = true;
      # };
      # gtk4.extraConfig = {
      #   gtk-application-prefer-dark-theme = true;
      # };
    };

    xresources.properties = {
      "Xft.antialias" = 1;
      "Xft.autohint" = 0;
      "Xft.hinting" = 1;
      "Xft.hintstyle" = "hintnone";
      "Xft.rgba" = "rgb";
      "Xft.lcdfilter" = "lcddefault";
    };

    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };

    # xdg.desktopEntries = {
    #   numbat = {
    #     name = "Numbat";
    #     genericName = "Calculator";
    #     exec = "${lib.getExe pkgs.numbat}";
    #     terminal = true;
    #     categories = [
    #       "Application"
    #     ];
    #   };
    # };
    programs.hyprlock.enable = false;
    programs.hyprlock.settings = {
      general = {
        disable_loading_bar = true;
        grace = 300;
        hide_cursor = true;
        no_fade_in = false;
      };

      background = [
        {
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
        }
      ];

      input-field = [
        {
          size = "200, 50";
          position = "0, -80";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          font_color = "rgb(202, 211, 245)";
          inner_color = "rgb(91, 96, 120)";
          outer_color = "rgb(24, 25, 38)";
          outline_thickness = 5;
          placeholder_text = "Password...";
          shadow_passes = 2;
        }
      ];
    };
  };
}
