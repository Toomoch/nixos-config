{ pkgs, lib, ... }:
let
  filemanager = "thunar";
  browser = "firefox";
  extraCss = ''
    /* No (default) title bar on wayland */
    headerbar.default-decoration {
      /* You may need to tweak these values depending on your GTK theme */
      margin-bottom: 50px;
      margin-top: -100px;
    }

    /* rm -rf window shadows */
    window.csd,             /* gtk4? */
    window.cgd decoration { /* gtk3 */
      box-shadow: none;
    }
  '';
  riverspawn = pkgs.writeShellScriptBin "riverspawn"
    (builtins.readFile ./dotfiles/riverspawn.sh);
in {
  home.packages = [ pkgs.waylock ];
  wayland.windowManager.river = {
    enable = true;
    package = null;
    extraConfig = builtins.readFile ./dotfiles/riverinit.sh;
    systemd.extraCommands = [
      "systemctl --user stop river-session.target"
      "systemctl --user start river-session.target"
      "${lib.getExe riverspawn}"
    ];
  };
  services.kanshi.systemdTarget = "river-session.target";
  gtk.gtk4.extraCss = extraCss;
  gtk.gtk3.extraCss = extraCss;

}
