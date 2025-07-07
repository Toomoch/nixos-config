{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  huawei-solar,
}:

buildHomeAssistantComponent rec {
  owner = "hectorespert";
  domain = "som_energia";
  version = "2025.05.20";

  src = fetchFromGitHub {
    inherit owner;
    repo = "som-energia-hass";
    rev = version;
    hash = "sha256-P51G/FRXJeCsOMy7PmDLIx1teT/VrpTRdXix2nU+6tM=";
  };

  meta = with lib; {
    description = "Integration for Home Assistant of Som Energia";
    homepage = "https://github.com/hectorespert/som-energia-hass";
    changelog = "https://github.com/hectorespert/som-energia-hass/releases/tag/${version}";
    maintainers = with maintainers; [ Toomoch ];
    license = licenses.asl20;
  };
}
