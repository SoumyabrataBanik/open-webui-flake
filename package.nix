{ pkgs, pname, version, src }:
    let
        frontend = import ./frontend.nix {
            inherit pkgs pname version src;
        };
    in

import ./backend.nix {
    inherit pkgs pname version src frontend;
}
