pkgs: nixvim: system: rec {
  huawei_solar = pkgs.callPackage ./huawei_solar.nix { inherit huawei-solar; };
  huawei-solar = pkgs.callPackage ./huawei-solar.nix {
    inherit (pkgs.home-assistant.python.pkgs)
      backoff hatchling hatch-vcs pytz pymodbus pyserial-asyncio
      typing-extensions pytest-asyncio pytestCheckHook buildPythonPackage;
  };
  som-energia-hass = pkgs.callPackage ./som-energia-hass.nix { };
  nvim = nixvim.legacyPackages.${system}.makeNixvimWithModule {
    module = ../nixvim;
  };
  help-blog = pkgs.callPackage ./blog.nix { };
  notion_todo = pkgs.callPackage ./notion_todo.nix { };

}
