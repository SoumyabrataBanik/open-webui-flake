{ pkgs, ... }:

let
  pname = "open-webui";
  version = "0.6.25";
in

{
  pname = pname;
  version = version;

  src = pkgs.fetchFromGitHub {
    owner = "open-webui";
    repo = "open-webui";
    tag = "v${version}";
    hash = "sha256-G637A6Iof1REYznsKhY/gWL1sv4vL8CNmZNhqMlV4FA=";
  };
}
