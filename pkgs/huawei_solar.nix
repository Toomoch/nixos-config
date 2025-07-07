{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  huawei-solar,
}:

buildHomeAssistantComponent rec {
  owner = "wlcrs";
  domain = "huawei_solar";
  version = "1.5.5";

  src = fetchFromGitHub {
    owner = "wlcrs";
    repo = "huawei_solar";
    rev = version;
    hash = "sha256-6vtYN4b1IFpyRy3KiEs3r2RswQBK7Vq2N6aZXtZEBqo=";
  };

  dependencies = [ huawei-solar ];

  meta = with lib; {
    description = "Home Assistant integration for Huawei Solar inverters via Modbus";
    homepage = "https://github.com/wlcrs/huawei_solar";
    changelog = "https://github.com/wlcrs/huawei_solar/releases/tag/${version}";
    maintainers = with maintainers; [ Toomoch ];
    license = licenses.agpl3Only;
  };
}
