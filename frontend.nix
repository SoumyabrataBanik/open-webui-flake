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
  pyodideVersion = "0.28.2";
  pyodide = pkgs.fetchurl {
    url = "https://github.com/pyodide/pyodide/releases/download/${pyodideVersion}/pyodide-${pyodideVersion}.tar.bz2";
    sha256 = "sha256-MQIRdOj9yVVsF+nUNeINnAfyA6xULZFhyjuNnV0E5+c=";
  };

  npmDepsHash = "sha256-vsgdf7+h16VBF+bTxzdNeHNzsYV65KWNZ6Ga3N7fB5A=";

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
