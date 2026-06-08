{ pkgs ? import <nixpkgs> {} }:
let
  braveOriginData = { version = "1.91.168"; hash = "sha256-OamzE+0k2u/p3W2eG90N2x942t9wB10R7d620H60Qj8="; url = "https://brave-browser-apt-origin-release.s3.brave.com/pool/main/b/brave-origin/brave-origin_1.91.168_amd64.deb"; };
in
(pkgs.callPackage "${pkgs.path}/pkgs/by-name/br/brave/make-brave.nix" {} {
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
    [ "opt/brave.com/brave-origin/brave" ]
    old.installCheckPhase;
  meta = old.meta // {
    mainProgram = "brave-origin";
  };
})
