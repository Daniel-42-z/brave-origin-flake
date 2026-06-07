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
        packages.brave-origin = pkgs.callPackage "${nixpkgs}/pkgs/by-name/br/brave/make-brave.nix" {} {
          pname = "brave-origin";
          version = braveOriginData.version;
          hash = braveOriginData.hash;
          url = braveOriginData.url;
        };

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
