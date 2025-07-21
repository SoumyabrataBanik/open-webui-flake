{
    description = "A flake for Open-Webui";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    };

    outputs = { self, nixpkgs }:
        let
            supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
            forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
        in
        {
            packages = forAllSystems (system:
                let
                    pkgs = nixpkgs.legacyPackages.${system};
                    source-attrs = import ./source-info.nix { inherit pkgs; };
                in
                {
                    default = pkgs.callPackage ./package.nix (source-attrs);
                    
                    # Since we have no other arguments to pass here, we're not adding // and attr set here otherwise we could also do:
                    # default = pkgs.callPackage ./package.nix (source-attrs // {
                    #   Any argument change goes here
                    #})
                }
            );

        };
}
