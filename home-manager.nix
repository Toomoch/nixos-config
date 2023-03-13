{ config, pkgs, lib, ... }:

{
  #home-manager
  home-manager.useGlobalPkgs = true;
  home-manager.users.arnau = { pkgs, ... }: {

    imports = [
      ./sway
    ];

    programs.git = {
      enable = true;
      userName = "Toomoch";
      userEmail = "vallsfustearnau@gmail.com";
    };



    programs.bash = {
      enable = true;
      bashrcExtra = ''
        eval "$(starship init bash)"
      '';
      profileExtra = ''
        [ "$(tty)" = "/dev/tty1" ] && exec sway
      '';
      sessionVariables = {
        MOZ_ENABLE_WAYLAND = 1;
      };
      shellAliases = {
        ls = "ls --color=auto -l";
        ".." = "cd ..";
        upcdown = "rclone copy upc:/assig ~/assig/ --drive-acknowledge-abuse -P";
        upcup = "rclone copy ~/assig/ upc:/assig/ --drive-acknowledge-abuse -P";
        upcsync = "upcdown && upcup";
        nixrebuild = "sudo nixos-rebuild switch -I nixos-config=configuration.nix";
        codium = "codium --ozone-platform-hint=auto";
      };

    };

    programs.vscode = {
      enable = true;
      package = pkgs.vscodium-fhs;
      userSettings = {
        editor = {
          fontFamily = "'Noto Sans Mono','Fira Code','Font Awesome 6 Free','Font Awesome 6 Brands','Font Awesome 6 Free Solid', monospace";
          fontLigatures = true;
        };

        window.titleBarStyle = "custom";

        workbench = {
          iconTheme = "material-icon-theme";
          colorTheme = "GitHub Dark";
        };

        files.autoSave = "afterDelay";

        redhat.telemetry.enabled = false;

        clangd.fallbackFlags = [
          "-I\${workspaceFolder}/include"
        ];

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
    };

    qt = {
      enable = true;
      platformTheme = "gtk";
    };





    home.stateVersion = "22.11";
  };
}
