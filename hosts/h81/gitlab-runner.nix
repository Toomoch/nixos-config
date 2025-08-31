{
  private,
  config,
  pkgs,
  lib,
  ...
}:
{

  age.secrets.gitlab-runner = {
    rekeyFile = /${private}/secrets/age/runner-h81.age;
    owner = "gitlab-runner";
    group = "gitlab-runner";
  };

  users.users."gitlab-runner" = {
    group = "gitlab-runner";
    isSystemUser = true;
  };

  users.groups."gitlab-runner" = { };

  systemd.services.gitlab-runner.serviceConfig = {
    DynamicUser = lib.mkForce false;
    User = "gitlab-runner";
    Group = "gitlab-runner";
  };

  services.gitlab-runner = {
    enable = true;
    services = {
      nix = {
        authenticationTokenConfigFile = config.age.secrets.gitlab-runner.path;
        executor = "shell";
      };

    };
  };
}
