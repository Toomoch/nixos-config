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
  version = "2.4.4";
  pyproject = true;

  src = fetchFromGitLab {
    owner = "Emilv2";
    repo = pname;
    rev = "749601842f33b161ed75d05eaf2d97be0f56f10e";
    hash = "sha256-Gr4JoSgD0CQoujNyanTuvewsrP8MoSD0LlJTGtx1Ir4=";
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

