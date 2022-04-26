{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.blackfire;
  agent = cfg.package;
  blackfireAgent = pkgs.blackfire;

in {
  options = {
    services.blackfire = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description =
          "\n          Whether to enable the Blackfire Agent\n        ";
      };

      package = mkOption {
        type = types.package;
        default = blackfireAgent;
        description = "\n          Blackfire Agent\n        ";
      };

      server-id = mkOption {
        type = types.str;
        default = "";
        description = ''
          Sets the server id used to authenticate with Blackfire
          You can find your personal server-id at https://blackfire.io/my/settings/credentials
        '';
      };

      server-token = mkOption {
        type = types.str;
        default = "";
        description = ''
          Sets the server token used to authenticate with Blackfire
          You can find your personal server-token at https://blackfire.io/my/settings/credentials
        '';
      };
    };
  };

  ###### implementation

  config = mkIf config.services.blackfire.enable {
    environment.systemPackages = [ cfg.package ];

    launchd.user.agents.blackfire = let config = pkgs.writeText "agent.ini" ""; in {
      path = [ cfg.package ];
      script = ''
        export BLACKFIRE_SERVER_ID="${cfg.server-id}"
        export BLACKFIRE_TOKEN_ID="${cfg.server-token}"
        export BLACKFIRE_SOCKET="tcp://127.0.0.1:8307"

        exec ${cfg.package}/bin/blackfire agent --config=${config}
      '';
      serviceConfig.KeepAlive = true;
      serviceConfig.RunAtLoad = true;
    };
  };
}
