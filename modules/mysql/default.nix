{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.mysql;
  mysql = cfg.package;
  isMariaDB = getName mysql == getName pkgs.mariadb;
  mysqldOptions =
    "--defaults-file=/etc/my.cnf --datadir=${cfg.dataDir} --basedir=${mysql}";
in

{
  options = {
    services.mysql = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "
          Whether to enable the MySQL server.
        ";
      };

      package = mkOption {
        type = types.package;
        default = pkgs.mysql80;
        description = "
          Which MySQL derivation to use. MariaDB packages are supported too.
        ";
      };

      bind = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = literalExample "0.0.0.0";
        description = "Address to bind to. The default is to bind to all addresses.";
      };

      port = mkOption {
        type = types.port;
        default = 3306;
        description = "Port of MySQL.";
      };

      dataDir = mkOption {
        type = types.path;
        default = "/opt/nix/mysql";
        description = "Location where MySQL stores its table files.";
      };

      socketFile = mkOption {
        type = types.str;
        default = "/tmp/mysql.sock";
      };

      extraOptions = mkOption {
        type = types.lines;
        default = "";
        example = ''
          key_buffer_size = 6G
          table_cache = 1600
          log-error = /var/log/mysql_err.log
        '';
        description = ''
          Provide extra options to the MySQL configuration file.

          Please note, that these options are added to the
          <literal>[mysqld]</literal> section so you don't need to explicitly
          state it again.
        '';
      };
    };
  };

  ###### implementation

  config = mkIf config.services.mysql.enable {
    environment.systemPackages = [ mysql ];
    environment.etc."my.cnf".text =
    ''
      [mysqld]
      port = ${toString cfg.port}
      datadir = ${cfg.dataDir}
      socket = ${cfg.socketFile}
      ${optionalString (cfg.bind != null) "bind-address = ${cfg.bind}" }
      ${cfg.extraOptions}
      [mysql]
      socket = ${cfg.socketFile}
    '';

    launchd.user.agents.mysql =
      { path = [ pkgs.coreutils pkgs.gnused mysql ];
        script = ''
          # Initialize the database
          if ! test -e ${cfg.dataDir}/mysql; then
            ${if isMariaDB then "${mysql}/bin/mysql_install_db" else "${mysql}/bin/mysqld"} ${mysqldOptions} ${optionalString (!isMariaDB) "--initialize-insecure"}
          fi

          exec ${cfg.package}/bin/mysqld ${mysqldOptions}
        '';
        serviceConfig.KeepAlive = true;
        serviceConfig.RunAtLoad = true;
      };
  };
}
