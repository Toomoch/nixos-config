{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  huawei-solar,
}:

buildHomeAssistantComponent rec {
  owner = "wlcrs";
  domain = "huawei_solar";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "wlcrs";
    repo = "huawei_solar";
    rev = version;
    hash = "sha256-XUrNavmo4y7dOjlTvb+hvtqnwmVfcK7ervC7oUQV18M=";
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
