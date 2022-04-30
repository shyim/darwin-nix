
{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.programs.rclone;
  configOptions = types.nullOr (types.oneOf [
        types.bool
        types.int
        types.float
        types.str
        (types.lazyAttrsOf configOptions)
        (types.listOf configOptions)
      ]) // {
        emptyValue.value = { };
      };

in {
    options.programs.rclone = {
        enable = mkEnableOption "rclone";

        package = mkOption {
            type = types.package;
            default = pkgs.rclone;
            defaultText = literalExpression "pkgs.rclone";
            description = "The package to use for rclone.";
        };

        settings = mkOption {
            type = configOptions;
            default = {};
        };
    };

    config = mkIf cfg.enable {
        # Install rclone
        home.packages = [ cfg.package ];

        xdg.configFile."rclone/rclone.conf" = mkIf (cfg.settings != { }) {
            text = lib.generators.toINI {} cfg.settings;
        };
    };
}