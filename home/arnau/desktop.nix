{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    #desktop apps
    gnome.nautilus
    gnome.gnome-disk-utility
    gnome.file-roller
    pavucontrol
    kooha
    gnome.gnome-calculator
    onlyoffice-bin
    tdesktop
    scrcpy
    virt-manager
    gnome-network-displays
    gitg
    thunderbird
    openlens
  ];

  home.file."${config.xdg.userDirs.pictures}/wallpapers/" = {
    source = ./wallpapers;
    recursive = true;
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
      defaultApplications = 
        #"inode/directory" = "org.gnome.Nautilus.desktop";
        #"application/zip" = "org.gnome.FileRoller.desktop";
        config.lib.xdg.mimeAssociations [ 
          pkgs.gnome.nautilus
          pkgs.gnome.file-roller
          pkgs.mpv
          pkgs.firefox
         ];
        #"video/x-matroska" = "mpv.desktop";
        #"image/png" = "firefox.desktop";
      
      associations.added = {
        "application/pdf" = "firefox.desktop";
        "image/png" = "firefox.desktop";
        "video/x-matroska" = "mpv.desktop";
      };
    };
  };

  programs.alacritty = {
    enable = true;
    settings = {
      window.opacity = 0.8;
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
        font = "Noto Sans Mono:size=12";
        dpi-aware = "no";
      };
      colors = {
        background = "242424";
        foreground = "ffffff";
      };
    };
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;

    userSettings = {
      editor = {
        fontFamily = "'Noto Sans Mono','Fira Code','Font Awesome 6 Free','Font Awesome 6 Brands','Font Awesome 6 Free Solid', monospace";
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

      clangd.fallbackFlags = [
        "-I\${workspaceFolder}/include"
      ];

      update.mode = "none";
      nix.enableLanguageServer = true;
      nix.serverPath = "nil";
      nix.serverSettings.nil = {
        formatting = {
          command = [ "nixpkgs-fmt" ];
        };
        flake = {
          autoArchive = true;
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

  programs.mpv = {
    enable = true;
    config = { hwdec = "auto"; };
  };


  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.gnome.adwaita-icon-theme;
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
      package = pkgs.gnome.adwaita-icon-theme;
    };
    font = {
      name = "Rubik";
      package = pkgs.rubik;
      size = 11;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
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
}
