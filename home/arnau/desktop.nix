{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    #dev tools
    llvmPackages_15.libclang
    nixpkgs-fmt
    nixfmt
    erlang
    gnumake
    jetbrains.idea-community

    #desktop apps
    gnome.nautilus
    gnome.gnome-disk-utility
    gnome.file-roller
    pavucontrol
    kooha
    gnome.gnome-calculator
    onlyoffice-bin
    tdesktop
  ];

  programs.alacritty.enable = true;

  programs.java = {
    enable = true;
    package = pkgs.jdk11;
  };

  

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium.fhsWithPackages (ps: with ps; [ jdk17]);

    userSettings = {
      editor = {
        fontFamily = "'Noto Sans Mono','Fira Code','Font Awesome 6 Free','Font Awesome 6 Brands','Font Awesome 6 Free Solid', monospace";
        fontLigatures = true;
      };

      window.titleBarStyle = "none";

      workbench = {
        iconTheme = "material-icon-theme";
        colorTheme = "GitHub Dark";
      };

      files.autoSave = "afterDelay";

      redhat.telemetry.enabled = false;

      clangd.fallbackFlags = [
        "-I\${workspaceFolder}/include"
      ];

      update.mode = "none";

      java.jdt.ls.java.home = "${pkgs.jdk17}";
    };

  };

  home.activation.boforeCheckLinkTargets = {
      after = [];
      before = [ "checkLinkTargets" ];
      data = ''
        userDir=/arnau/grmpf/.config/VSCodium/User
        rm -rf $userDir/settings.json
      '';
    };

    home.activation.afterWriteBoundary = {
      after = [ "writeBoundary" ];
      before = [];
      data = ''
        userDir=/home/arnau/.config/VSCodium/User
        rm -rf $userDir/settings.json
        cat \
          ${(pkgs.formats.json {}).generate "blabla"
            config.programs.vscode.userSettings} \
          > $userDir/settings.json
      '';
    };

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

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };
}
