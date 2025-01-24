{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  huawei-solar,
}:

buildHomeAssistantComponent rec {
  owner = "hectorespert";
  domain = "som_energia";
  version = "2024.12.16";

  src = fetchFromGitHub {
    inherit owner;
    repo = "som-energia-hass";
    rev = version;
    hash = "sha256-3zSZD0gE1cACdJjcnlqucmkm0q06r01pgDsubs2Tt98=";
  };

  meta = with lib; {
    description = "Integration for Home Assistant of Som Energia";
    homepage = "https://github.com/hectorespert/som-energia-hass";
    changelog = "https://github.com/hectorespert/som-energia-hass/releases/tag/${version}";
    maintainers = with maintainers; [ Toomoch ];
    license = licenses.asl20;
  };
}
