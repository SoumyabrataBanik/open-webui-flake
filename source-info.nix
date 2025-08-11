{ pkgs, ... }:

let
  pname = "open-webui";
  version = "0.6.22";
in

{
  pname = pname;
  version = version;

  src = pkgs.fetchFromGitHub {
    owner = "open-webui";
    repo = "open-webui";
    tag = "v${version}";
    hash = "sha256-SX2uLmDZu1TW45A6F5mSXVtSqv5rbNKuVw8sWj8tEb4=";
  };
}
