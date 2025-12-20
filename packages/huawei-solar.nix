{
  backoff,
  buildPythonPackage,
  fetchFromGitLab,
  lib,
  hatchling,
  hatch-vcs,
  pytz,
  pymodbus,
  pyserial-asyncio,
  typing-extensions,
  pytest-asyncio,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "huawei-solar";
  version = "2.5.0";
  pyproject = true;

  src = fetchFromGitLab {
    owner = "Emilv2";
    repo = pname;
    rev = "f328a21d7e23134b7c4ff2aba8f3ea2b025197fa";
    hash = "sha256-ikctsUSb0jz3w6Ph17DJR5IN/GrN8xI6oJfQmcgAZbs=";
  };

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    backoff
    pytz
    pymodbus
    typing-extensions
    pyserial-asyncio
  ];

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  meta = with lib; {
    description = "Python library for connecting to Huawei SUN2000 Inverters over Modbus";
    homepage = "https://gitlab.com/Emilv2/huawei-solar/";
    changelog = "https://gitlab.com/Emilv2/huawei-solar/-/tags/${version}";
    maintainers = with maintainers; [ Toomoch ];
    license = licenses.agpl3Only;
    # broken = lib.versionAtLeast pymodbus.version "3.7.0";
  };

}

