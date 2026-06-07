# Brave Origin Flake

A [Nix Flake](https://nixos.wiki/wiki/Flakes) that packages [Brave Origin](https://brave.com/origin/) for NixOS and provides a drop-in [Home Manager](https://github.com/nix-community/home-manager) module.

Brave Origin is a minimalist, debloated version of the Brave Browser that removes non-core revenue-generating features (like Brave Rewards, Wallet, AI, and VPN) while maintaining its signature privacy protections and ad-blocking capabilities.

Since Brave officially distributes Linux builds via their APT repositories, this flake automatically pulls the latest `.deb` release, unpacks it, and patches the binaries using the native Nixpkgs `make-brave.nix` routine to run beautifully on NixOS.

## Features

- **Always up-to-date**: Automatically checks for updates daily via a GitHub Actions workflow that parses the official APT `Packages` repository.
- **Home Manager Integration**: Provides a `programs.brave-browser` module that exactly mirrors the options of Home Manager's standard `programs.brave` module (including declarative extensions and command-line arguments).

## Usage

### Using Home Manager (Recommended)

You can import the module and enable the browser directly in your Home Manager configuration:

```nix
{ inputs, pkgs, ... }:
{
  imports = [
    inputs.brave-origin.homeManagerModules.default
  ];

  # The options are exactly the same as the standard programs.brave module
  programs.brave-browser = {
    enable = true;
    
    # Example: install extensions
    extensions = [
      "hlbgchjfepnbkdeoeoehinocffkellai" # GitHub refined
    ];
    
    # Example: pass command line arguments
    commandLineArgs = [
      "--disable-features=WebRtcHideLocalIpsWithMdns"
    ];
  };
}
```

### NixOS (System-wide)

If you just want to install the package without Home Manager, you can add it to your `environment.systemPackages` in `configuration.nix`:

```nix
{ inputs, pkgs, ... }:
{
  environment.systemPackages = [
    inputs.brave-origin.packages.${pkgs.system}.default
  ];
}
```

## Running standalone

You can test or run the browser directly without installing it by using `nix run`:

```bash
nix run github:Daniel-42-z/brave-origin-flake
```

## Maintenance

This flake uses an automated script to stay up-to-date with upstream. The `.github/workflows/update.yml` runs daily to check the Brave APT repository, hash the new `.deb` file, update `versions.json`, and automatically merge a Pull Request if checks pass.

To update it manually, simply drop into the devShell and run the script:

```bash
nix develop
./scripts/update-version.sh
```
