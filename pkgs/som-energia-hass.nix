{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  holidays,
}:

buildHomeAssistantComponent rec {
  owner = "hectorespert";
  domain = "som_energia";
  version = " 2025.12.14";

  src = fetchFromGitHub {
    inherit owner;
    repo = "som-energia-hass";
    rev = version;
    hash = lib.fakeHash;
  };

  dependencies = [
    holidays
  ];

  meta = with lib; {
    description = "Integration for Home Assistant of Som Energia";
    homepage = "https://github.com/hectorespert/som-energia-hass";
    changelog = "https://github.com/hectorespert/som-energia-hass/releases/tag/${version}";
    maintainers = with maintainers; [ Toomoch ];
    license = licenses.asl20;
  };
}
