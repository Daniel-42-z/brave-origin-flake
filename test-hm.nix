let
  pkgs = import <nixpkgs> {};
  hm = import (builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz") { inherit pkgs; };
in
hm.homeManagerConfiguration {
  pkgs = pkgs;
  modules = [
    {
      home.username = "test";
      home.homeDirectory = "/home/test";
      home.stateVersion = "23.11";
      programs.brave = {
        enable = true;
        package = pkgs.runCommand "dummy-brave" { meta.mainProgram = "dummy-exe"; } "mkdir -p $out/bin && touch $out/bin/dummy-exe && chmod +x $out/bin/dummy-exe";
        commandLineArgs = [ "--foo" ];
      };
    }
  ];
}
