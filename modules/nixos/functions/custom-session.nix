{ pkgs, lib, name, exec ? null }:

let
  name-exec = if exec != null then exec else name;

  launch = pkgs.writeScriptBin "launch" ''
    export XDG_SESSION_DESKTOP=${name}
    export XDG_CURRENT_DESKTOP=${name}
    export XDG_SESSION_TYPE=wayland

    exec systemd-cat --identifier=${name} ${name-exec} $@
  '';

  custom-raw = pkgs.writeTextFile {
    name = "${name}-custom-desktop-entry";
    destination = "/share/wayland-sessions/${name}-custom.desktop";
    text = ''
      [Desktop Entry]
      Name=${name} (Custom)
      Comment=${name}
      Exec=${lib.getExe launch}
      Type=Application
    '';
    passthru.providedSessions = [ "${name}-custom" ];
  };

in custom-raw
