{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
}:

buildHomeAssistantComponent rec {
  owner = "JanGiese";
  domain = "notion_todo";
  version = "1.1.1";

  src = fetchFromGitHub {
    inherit owner;
    repo = "notion_todo";
    rev = version;
    hash = "sha256-J6NE10KFS1jSht9w3ZG99CO2UJH8pejbY4yBh/hBcJE=";
  };

  meta = with lib; {
    description = "ToDo Integration for Notion and HomeAssistant ";
    homepage = "https://github.com/JanGiese/notion_todo";
    changelog = "https://github.com/JanGiese/notion_todo/releases/tag/${version}";
    maintainers = with maintainers; [ Toomoch ];
    license = licenses.mit;
  };
}
