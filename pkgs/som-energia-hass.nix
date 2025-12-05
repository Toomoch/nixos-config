{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  huawei-solar,
  holidays,
}:

buildHomeAssistantComponent rec {
  owner = "hectorespert";
  domain = "som_energia";
  version = "2025.11.29";

  src = fetchFromGitHub {
    inherit owner;
    repo = "som-energia-hass";
    rev = version;
    hash = "sha256-Enjhzcmz7nJ63D0O+Sj7H2UqgxzbNwFFiY0ixZwp5FQ=";
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
