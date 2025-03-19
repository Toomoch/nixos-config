{ pkgs, self, ... }:
let
  defaultHosts = builtins.attrNames self.nixosConfigurations;
  defaultServices = [
    "grafana"
    "home-assistant"
  ];

  servicedebug = pkgs.writeShellScriptBin "servicedebug" ''
    function dmenu_with_defaults() {
      local prompt="$1"
      shift
      local options=("$@")
      
      selection=$(printf '%s\n' "''${options[@]}" | fuzzel --no-exit-on-keyboard-focus-loss --dmenu --font="NotoSansM Nerd Font Mono:size=20" -i -p "$prompt")
      echo "$selection"
    }

    HOST=$(dmenu_with_defaults "host: " ${toString defaultHosts})

    # Exit if no host
    if [ -z "$HOST" ]; then
      exit 0
    fi

    services=$(ssh "$HOST" "systemctl list-units --type=service --all --no-pager --plain --no-legend | awk '{print \$1}'")

    SERVICE=$(dmenu_with_defaults "service: " "$services")

    # Exit if no service
    if [ -z "$SERVICE" ]; then
      exit 0
    fi

    ${pkgs.alacritty}/bin/alacritty -e ssh "$HOST" "sudo journalctl -u $SERVICE -f" &

    # Exit the script while alacritty continues running
    exit 0
  '';
in
{
  programs.git = {
    userName = "Toomoch";
    userEmail = "vallsfustearnau@gmail.com";
  };
  home.packages = [ servicedebug ];

  xdg.desktopEntries = {
    corednsdebug = {
      name = "Remote service debug";
      comment = "Debug systemd services";
      exec = "servicedebug";
      icon = "utilities-terminal"; # Using a standard icon, replace with custom icon if available
      categories = [
        "System"
        "Network"
        "Development"
        "Utility"
      ];
      terminal = false; # Set to false since it launches its own terminals
      startupNotify = true;
      type = "Application";
    };
  };

}
