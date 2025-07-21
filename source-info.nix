{ pkgs, ... }:

let
    pname = "open-webui";
    version = "0.6.18";
in

{
    pname = pname;
    version = version;

    src = pkgs.fetchFromGitHub {
        owner = "open-webui";
        repo = "open-webui";
        tag = "v${version}";
        hash = "sha256-1V9mOhO8jpr0HU0djLjKw6xDQMBmqie6Gte4xfg9PfQ=";
    };
}
