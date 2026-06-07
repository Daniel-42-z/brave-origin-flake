{ config, lib, pkgs, ... }:

let
  cfg = config.programs.brave-browser;
  inherit (lib) mkEnableOption mkOption types mkIf literalExpression;
in
{
  options.programs.brave-browser = {
    enable = mkEnableOption "Brave Browser (Origin)";

    package = mkOption {
      type = types.package;
      # We default to the flake's brave-origin if available
      default = pkgs.brave-origin or pkgs.brave;
      defaultText = literalExpression "pkgs.brave-origin";
      description = "The brave-origin package to use.";
    };

    extensions = mkOption {
      type = types.listOf (types.either types.str (types.submodule {
        options = {
          id = mkOption { type = types.str; };
          updateUrl = mkOption { type = types.str; default = "https://clients2.google.com/service/update2/crx"; };
        };
      }));
      default = [ ];
      example = literalExpression ''
        [
          "hlbgchjfepnbkdeoeoehinocffkellai" # GitHub refined
        ]
      '';
      description = "List of Chromium extensions to install.";
    };

    commandLineArgs = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "List of command line arguments to pass to the browser.";
    };
  };

  config = mkIf cfg.enable {
    # We map these options directly to programs.brave from home-manager,
    # which already contains all the complex logic for extensions and args.
    programs.brave = {
      enable = true;
      package = cfg.package;
      extensions = cfg.extensions;
      commandLineArgs = cfg.commandLineArgs;
    };
  };
}
