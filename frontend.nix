# Majority chunk of this code has been inspired from the official Open-WebUI nixpkgs
# To study the code, visit: https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/op/open-webui/package.nix#L216

{
  pkgs,
  pname,
  version,
  src,
}:

pkgs.buildNpmPackage rec {

  inherit pname version src;

  # This is the backend for the run-on-client browser python execution
  # Must match the lock file in Open-WebUI official repo.
  pyodideVersion = "0.27.3";
  pyodide = pkgs.fetchurl {
    url = "https://github.com/pyodide/pyodide/releases/download/${pyodideVersion}/pyodide-${pyodideVersion}.tar.bz2";
    sha256 = "sha256-SeK3RKqqxxLLf9DN5xXuPw6ZPblE6OX9VRXMzdrmTV4=";
  };

  npmDepsHash = "sha256-WL1kdXn7uAaBEwWiIJzzisMZ1uiaOVtFViWK/kW6lsY=";

  npmFlags = [ "--legacy-peer-deps" ];

  # Apparently it is recommended to disable pyodide:fetch as it downloads packages during buildPhase
  # This apparently causes problems while running python packages from the browser
  postPatch = ''
    substituteInPlace package.json \
        --replace-fail "npm run pyodide:fetch && vite build" "vite build"
  '';

  # I have no idea why ffmpeg-headless is being used here in the official Open-WebUI nixpkgs.
  # I am keeping this here in case I understand its purpose in the future
  #propagatedBuildInputs = with pkgs; [
  #    ffmpeg-headless
  #];

  env.CYPRESS_INSTALL_BINARY = "0"; # disallow cypress from downloading binaries in sandbox
  env.ONNXRUNTIME_NODE_INSTALL_CUDA = "skip";
  env.NODE_OPTIONS = "--max-old-space-size=8192";

  preBuild = ''
    tar -xf ${pyodide} -C static/
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/frontend
    cp -r build/* $out/frontend

    runHook postInstall
  '';

  dontFixup = true;
}
