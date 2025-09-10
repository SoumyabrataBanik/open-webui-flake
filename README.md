# Open-WebUI Nix Flake

[![Flake Build Checks](https://github.com/SoumyabrataBanik/open-webui-flake/actions/workflows/build.yml/badge.svg)](https://github.com/SoumyabrataBanik/open-webui-flake/actions/workflows/build.yml)

A continuously updated, declarative Nix flake for packaging [Open-WebUI](https://github.com/open-webui/open-webui). This project provides a robust, reproducible build of the latest version of Open-WebUI, ready for seamless integration into NixOS systems.

<p align="center">
    <strong>CURRENT VERSION: 0.6.26</strong>
</p>

## Description

Open WebUI is an extensible, feature-rich, and user-friendly self-hosted web interface for Large Language Models. This flake provides a self-contained package of the Open-WebUI frontend and backend server.

By leveraging the power of Nix, this flake ensures that the package is built in a pure, hermetic environment. The result is a bit-for-bit reproducible artifact that is reliable, portable, and easy to manage.

**Note:** This flake packages the Open-WebUI application itself. It does not include an LLM runner like Ollama, which must be installed and configured separately.

## Motivation

This project was born out of a desire to bridge the gap between Open-WebUI's rapid development pace and the release cycle of the official `nixpkgs` repository. While the official package is excellent, it can sometimes lag behind the latest upstream releases.

This flake aims to provide the Nix community with timely access to the newest features and bugfixes from Open-WebUI. It will be actively maintained to track the latest stable versions, offering a dependable way to deploy the cutting-edge of this fantastic tool.

## Features

*   **Up-to-Date:** Tracks recent versions of Open-WebUI.
*   **CPU-Based:** Provides a reliable, CPU-only build, avoiding the need for complex GPU/CUDA configurations.
*   **Modular Architecture:** A clean, separated build process for the frontend and backend, making it easy to maintain and debug.
*   **Fully Reproducible:** All dependencies, from Node modules to Pyodide assets and Python packages, are pinned and hashed for guaranteed build consistency.
*   **User-Friendly Configuration:** The package is pre-configured via a runtime wrapper to correctly handle its data directory at `~/.open-webui`, solving common file permission errors out of the box.

## Installation & Usage

This flake is designed to be integrated as an input into a NixOS system configuration. The process involves two main stages:
1.  **Making the package available** to your entire system using an overlay.
2.  **Installing the package** for your user, either via Home-Manager (recommended) or system-wide.

### Prerequisites

*   A working installation of Nix with Flakes enabled.
*   An existing, flake-based NixOS configuration.

### Stage 1: Make the Package Available System-Wide

First, add this flake as an input to your system's `flake.nix` and then apply it as an overlay. This makes the `open-webui` package visible to all other parts of your configuration.

#### 1. Add Flake Input

```nix
# /path/to/your/flake.nix
{
  inputs = {
    # ... your other inputs like nixpkgs, home-manager, etc.
    
    open-webui-flake = {
      url = "github:SoumyabrataBanik/open-webui-flake";
      # It is recommended to NOT add `inputs.nixpkgs.follows`.
      # This allows the flake to use its own locked version of nixpkgs,
      # ensuring it builds with the correct dependencies.
    };
  };

  # ...
}
```

#### 2. Add Overlay

In the same `flake.nix`, add the following inline module to your `homeConfiguration`. This overrides the `open-webui` package from `nixpkgs` with the up-to-date version from this flake. **This is the recommended method.**

```nix
# /path/to/your/home.nix
{
    homeConfigurations.your-username = home-manager.lib.homeManagerConfiguration {
        # ...
        modules = [
          ./configuration.nix

          # Add this inline module to define the overlay.
          # This makes `pkgs.open-webui` available everywhere in your system.
          ({
            nixpkgs.overlays = [
              (final: prev: {
                open-webui = open-webui-flake.packages.${prev.system}.default;
              })
            ];
          })
        ];
    }
}
```

If you want to install Open-WebUI for all users, then you will have to add the overlay in `nixosConfiguration`. Here is an example:

```nix
# /path/to/your/flake.nix
{
  # ... inside your outputs ...
  nixosConfigurations.your-hostname = nixpkgs.lib.nixosSystem {
    # ...
    modules = [
      ./configuration.nix

      # Add this inline module to define the overlay.
      # This makes `pkgs.open-webui` available everywhere in your system.
      ({
        nixpkgs.overlays = [
          (final: prev: {
            open-webui = open-webui-flake.packages.${prev.system}.default;
          })
        ];
      })
    ];
  };
}
```

### Stage 2: Install the Package

With the package now available as `pkgs.open-webui`, you can choose how to install it.

#### Method A: Via Home-Manager (Recommended)

This is the recommended method for user-specific applications. It keeps your user environment cleanly separated from the base system.

In your Home-Manager configuration (`home.nix` or a related file):

```nix
# /path/to/your/home.nix
{ pkgs, ... }:

{
  # 1. Install the package into your user profile.
  home.packages = [
    pkgs.open-webui
  ];

  # 2. (Optional) Create a shell alias for convenient launching on a custom port.
  programs.zsh.shellAliases = {
    ow = "${pkgs.open-webui}/bin/open-webui serve --port 3000";
  };
}
```

#### Method B: System-Wide Installation

If you prefer to make the package available to all users on the system, you can add it directly to `environment.systemPackages` in your NixOS configuration.

In your NixOS configuration (`configuration.nix` or a related file):

```nix
# /path/to/your/configuration.nix
{ pkgs, ... }:

{
  # Install the package for all users on the system.
  environment.systemPackages = [
    pkgs.open-webui
  ];
}
```
*Note: If you use this method, you will not have the custom `ow` alias. You would run the server by typing `open-webui serve` in your terminal.*

### Final Step: Rebuild and Run

#### Home-Manager

If you've decided to use home-manager to install Open-WebUI, then run:

```bash
home-manager switch --flake .
```

If you've decided to install it for all users, run the command:

```bash
sudo nixos-rebuild switch --flake .#your-hostname
```

**After the rebuild is complete, open a new terminal.**
- If you used the Home-Manager method, run your alias: `ow`
- If you used the system-wide method, run: `open-webui serve`

The server will start, and you can access it in your browser at the configured port (e.g., `http://localhost:3000`).

## Future Plans

This flake aims to be a comprehensive solution for deploying Open-WebUI. The following features are planned for future releases:

-   [ ] **NixOS Module:** Create a dedicated NixOS module to simplify deployment. This would allow users to configure Open-WebUI declaratively as a systemd service directly from their `configuration.nix`.

-   [ ] **GPU Support (CUDA):** Introduce an option to build the package with GPU acceleration enabled for users with NVIDIA hardware. This will require integration with the system's CUDA configuration for optimal performance of local ML models.

-   [ ] **Integrated Ollama:** Explore the possibility of packaging Ollama within the flake or providing it as part of the NixOS module, creating a truly all-in-one, self-contained AI environment.

## Acknowledgements

This flake stands on the shoulders of giants. A special thank you to the maintainers of the official `open-webui` package in `nixpkgs`. Their expert handling of the complex frontend build, especially the challenges surrounding Pyodide assets and Node.js dependencies, served as an invaluable guide and a foundation for this project.

## License

This project is licensed under the MIT License.
