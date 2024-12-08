pkgs: rec {
  # example = pkgs.callPackage ./example { };
  huawei_solar = pkgs.callPackage ./huawei_solar.nix { inherit huawei-solar; };
  huawei-solar = pkgs.callPackage ./huawei-solar.nix {
    inherit (pkgs.home-assistant.python.pkgs)
      backoff hatchling hatch-vcs pytz pymodbus pyserial-asyncio
      typing-extensions pytest-asyncio pytestCheckHook buildPythonPackage;
  };
}
