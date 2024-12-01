{ lib, python3, fetchFromGitHub, fetchFromGitLab }:
let
  python = python3.override {
    self = python;
    packageOverrides = (self: super: {
      pymodbus = super.pymodbus.overridePythonAttrs (oldAttrs: rec {
        version = "3.6.9";
        src = fetchFromGitHub {
          inherit (oldAttrs.src) owner repo;
          rev = "refs/tags/v${version}";
          hash = "sha256-ScqxDO0hif8p3C6+vvm7FgSEQjCXBwUPOc7Y/3OfkoI=";
        };
      });
    });
  };

in python.pkgs.buildPythonPackage rec {
  pname = "huawei-solar";
  version = "2.3.0";
  pyproject = true;

  src = fetchFromGitLab {
    owner = "Emilv2";
    repo = pname;
    rev = version;
    hash = "sha256-PcpyyEH3Ad9oyr4aPlUgxU5S/NPoIDUZj+Ncs7FXhVA=";
  };

  build-system = with python.pkgs; [ hatchling hatch-vcs ];
  dependencies = with python.pkgs; [
    backoff
    pytz
    pymodbus
    typing-extensions
    pyserial-asyncio
  ];

  meta = with lib; {
    description = "Python library for connecting to Huawei SUN2000 Inverters over Modbus";
    homepage = "https://gitlab.com/Emilv2/huawei-solar/";
    changelog = "https://gitlab.com/Emilv2/huawei-solar/-/tags/${version}";
    maintainers = with maintainers; [ Toomoch ];
    license = licenses.agpl3Only;
  };

}
