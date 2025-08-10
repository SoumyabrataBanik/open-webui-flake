{ pkgs, ... }:

let
  pname = "open-webui";
  version = "0.6.20";
in

{
  pname = pname;
  version = version;

  src = pkgs.fetchFromGitHub {
    owner = "open-webui";
    repo = "open-webui";
    tag = "v${version}";
    hash = "sha256-7eZKJOLs5PNRhjjbr1AFJu2y9Mmppl/50ZpT69A3WPY=";
  };
}
