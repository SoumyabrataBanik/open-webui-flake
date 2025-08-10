{ pkgs, ... }:

let
  pname = "open-webui";
  version = "0.6.21";
in

{
  pname = pname;
  version = version;

  src = pkgs.fetchFromGitHub {
    owner = "open-webui";
    repo = "open-webui";
    tag = "v${version}";
    hash = "sha256-S8CM7/SlvxVXK54B4a5i+m649rQsS9udOMCBxCqQ4JI=";
  };
}
