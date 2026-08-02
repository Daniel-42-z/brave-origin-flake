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
        packages.brave-origin = pkgs.lib.makeOverridable ({ vulkanSupport ? false, commandLineArgs ? "" }:
          let
            isOldNixpkgs = builtins.pathExists "${nixpkgs}/pkgs/by-name/br/brave/make-brave.nix";
            makeBravePath =
              if isOldNixpkgs then
                "${nixpkgs}/pkgs/by-name/br/brave/make-brave.nix"
              else
                "${nixpkgs}/pkgs/applications/networking/browsers/brave/make-brave.nix";
            
            oldDerivation = (pkgs.callPackage makeBravePath {
              inherit vulkanSupport commandLineArgs;
            } {
              pname = "brave-origin";
              version = braveOriginData.version;
              hash = braveOriginData.hash;
              url = braveOriginData.url;
            });

            newDerivation = pkgs.callPackage (import makeBravePath {
              pname = "brave-origin";
              version = braveOriginData.version;
              archives = {
                ${system} = {
                  url = braveOriginData.url;
                  hash = braveOriginData.hash;
                };
              };
              flavor = "origin";
              optStem = "brave-origin";
              fileStem = "brave-origin";
              appIdStem = "com.brave.Origin";
              darwinStem = "Brave Origin";
              changelogFile = "CHANGELOG.md";
              homepage = "https://brave.com/";
              innerBinary = "brave";
            }) {
              inherit vulkanSupport commandLineArgs;
            };

          in
          if isOldNixpkgs then
            oldDerivation.overrideAttrs (old: {
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
                  "$out/bin/brave"
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
                  "$out/bin/brave-origin"
                ]
                old.installPhase;
              
              installCheckPhase = builtins.replaceStrings
                [ "opt/brave.com/brave/brave" ]
                [ "opt/brave.com/brave-origin/brave-origin" ]
                old.installCheckPhase;

              meta = old.meta // {
                mainProgram = "brave-origin";
              };
            })
          else
            newDerivation.overrideAttrs (old: {
              installCheckPhase = ''
                $out/opt/brave.com/brave-origin/brave-origin --version
              '';
            })
        ) {};

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
