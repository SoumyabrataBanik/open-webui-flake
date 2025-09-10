{ pkgs, ... }:

let
  pname = "open-webui";
  version = "0.6.28";
in

{
  pname = pname;
  version = version;

  src = pkgs.fetchFromGitHub {
    owner = "open-webui";
    repo = "open-webui";
    tag = "v${version}";
    hash = "sha256-677M1IxWhdJ3AO8DPlW4eUYnOo/mCNu+11IPdaey9ks=";
  };
}
