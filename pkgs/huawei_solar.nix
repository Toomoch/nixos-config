{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  huawei-solar,
}:

buildHomeAssistantComponent rec {
  owner = "wlcrs";
  domain = "huawei_solar";
  version = "1.4.1";

  src = fetchFromGitHub {
    inherit owner;
    repo = "huawei_solar";
    rev = version;
    hash = "sha256-NQusnrXZOmRVVcX6a/GvwOeW62MrkypTG01+y+L6Ihs=";
  };

  patchPhase = ''
    mkdir -p custom_components/huawei_solar && \
    find . -mindepth 1 -maxdepth 1 -not -name custom_components -exec mv -t custom_components/huawei_solar {} +'';

  propagatedBuildInputs = [ huawei-solar ];

  meta = with lib; {
    description = "Home Assistant integration for Huawei Solar inverters via Modbus";
    homepage = "https://github.com/wlcrs/huawei_solar";
    changelog = "https://github.com/wlcrs/huawei_solar/releases/tag/${version}";
    maintainers = with maintainers; [ Toomoch ];
    license = licenses.agpl3Only;
  };
}
