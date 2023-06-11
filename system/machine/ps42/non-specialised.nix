{ config, lib, ... }:
{
  config = lib.mkIf (config.specialisation != { }) {
    desktop.sway.enable = true;
    # Power management 
    services.tlp = {
      enable = true;
      settings = {
        SOUND_POWER_SAVE_ON_AC = 1;
        SOUND_POWER_SAVE_ON_BAT = 1;
        RUNTIME_PM_ON_AC = "auto";
        PCIE_ASPM_ON_AC = "powersave";
        PCIE_ASPM_ON_BAT = "powersave";
      };
    };
  };
}
