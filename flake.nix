{
  description = "Brave Origin Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
        versions = builtins.fromJSON (builtins.readFile ./versions.json);
        braveOriginData = versions."brave-origin";
      in
      {
        packages.brave-origin = (pkgs.callPackage "${nixpkgs}/pkgs/by-name/br/brave/make-brave.nix" {} {
          pname = "brave-origin";
          version = braveOriginData.version;
          hash = braveOriginData.hash;
          url = braveOriginData.url;
        }).overrideAttrs (old: {
          installPhase = builtins.replaceStrings
            [
              "opt/brave.com/brave/brave-browser"
              "opt/brave.com/brave"
              "brave-browser,com.brave.Browser"
              "brave-browser.xml"
              "brave-browser.desktop"
              "com.brave.Browser.desktop"
              "/usr/bin/brave-browser-stable"
              "brave-browser.png"
            ]
            [
              "opt/brave.com/brave-origin/brave-origin"
              "opt/brave.com/brave-origin"
              "brave-origin,com.brave.Origin"
              "brave-origin.xml"
              "brave-origin.desktop"
              "com.brave.Origin.desktop"
              "/usr/bin/brave-origin-stable"
              "brave-origin.png"
            ]
            old.installPhase;
        });

        packages.default = self.packages.${system}.brave-origin;

        devShells.default = pkgs.mkShell {
          buildInputs = [ pkgs.jq pkgs.nix-prefetch ];
        };
      }
    ) // {
      homeManagerModules.brave-browser = import ./modules/brave-browser.nix;
      homeManagerModules.default = self.homeManagerModules.brave-browser;
    };
}
