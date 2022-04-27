{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.elasticsearch;
  es7 = builtins.compareVersions cfg.package.version "7" >= 0;

  esConfig = ''
    network.host: ${cfg.listenAddress}
    cluster.name: ${cfg.cluster_name}
    ${lib.optionalString cfg.single_node "discovery.type: single-node"}
    ${lib.optionalString (cfg.single_node && es7)
    "gateway.auto_import_dangling_indices: true"}
    http.port: ${toString cfg.port}
    transport.port: ${toString cfg.tcp_port}
    ${cfg.extraConf}
  '';

  configDir = cfg.dataDir + "/config";

  elasticsearchYml = pkgs.writeTextFile {
    name = "elasticsearch.yml";
    text = esConfig;
  };

  loggingConfigFilename = "log4j2.properties";
  loggingConfigFile = pkgs.writeTextFile {
    name = loggingConfigFilename;
    text = cfg.logging;
  };

  esPlugins = pkgs.buildEnv {
    name = "elasticsearch-plugins";
    paths = cfg.plugins;
    postBuild = "${pkgs.coreutils}/bin/mkdir -p $out/plugins";
  };

in {

  ###### interface

  options.services.elasticsearch = {
    enable = mkOption {
      description = "Whether to enable elasticsearch.";
      default = false;
      type = types.bool;
    };

    package = mkOption {
      description = "Elasticsearch package to use.";
      default = pkgs.elasticsearch;
      defaultText = literalExpression "pkgs.elasticsearch";
      type = types.package;
    };

    listenAddress = mkOption {
      description = "Elasticsearch listen address.";
      default = "127.0.0.1";
      type = types.str;
    };

    port = mkOption {
      description = "Elasticsearch port to listen for HTTP traffic.";
      default = 9200;
      type = types.int;
    };

    tcp_port = mkOption {
      description = "Elasticsearch port for the node to node communication.";
      default = 9300;
      type = types.int;
    };

    cluster_name = mkOption {
      description =
        "Elasticsearch name that identifies your cluster for auto-discovery.";
      default = "elasticsearch";
      type = types.str;
    };

    single_node = mkOption {
      description = "Start a single-node cluster";
      default = true;
      type = types.bool;
    };

    extraConf = mkOption {
      description = "Extra configuration for elasticsearch.";
      default = "";
      type = types.str;
      example = ''
        node.name: "elasticsearch"
        node.master: true
        node.data: false
      '';
    };

    logging = mkOption {
      description = "Elasticsearch logging configuration.";
      default = ''
        logger.action.name = org.elasticsearch.action
        logger.action.level = info
        appender.console.type = Console
        appender.console.name = console
        appender.console.layout.type = PatternLayout
        appender.console.layout.pattern = [%d{ISO8601}][%-5p][%-25c{1.}] %marker%m%n
        rootLogger.level = info
        rootLogger.appenderRef.console.ref = console
      '';
      type = types.str;
    };

    dataDir = mkOption {
      type = types.path;
      default = "/opt/nix/elasticsearch/";
      description = ''
        Data directory for elasticsearch.
      '';
    };

    extraCmdLineOptions = mkOption {
      description =
        "Extra command line options for the elasticsearch launcher.";
      default = [ ];
      type = types.listOf types.str;
    };

    extraJavaOptions = mkOption {
      description = "Extra command line options for Java.";
      default = [ ];
      type = types.listOf types.str;
      example = [ "-Djava.net.preferIPv4Stack=true" ];
    };

    plugins = mkOption {
      description = "Extra elasticsearch plugins";
      default = [ ];
      type = types.listOf types.package;
      example =
        lib.literalExpression "[ pkgs.elasticsearchPlugins.discovery-ec2 ]";
    };
  };

  ###### implementation

  config = mkIf cfg.enable {
    launchd.user.agents.elasticsearch = {
      script = ''
        set -e
        export ES_HOME="${cfg.dataDir}"
        export ES_JAVA_OPTS="${toString cfg.extraJavaOptions}"
        export ES_PATH_CONF="${configDir}"

        mkdir -m 0700 -p ${cfg.dataDir}

        # Install plugins
        rm -f ${cfg.dataDir}/plugins
        ln -sf ${esPlugins}/plugins ${cfg.dataDir}/plugins
        rm -f ${cfg.dataDir}/lib
        ln -sf ${cfg.package}/lib ${cfg.dataDir}/lib
        rm -f ${cfg.dataDir}/modules
        ln -sf ${cfg.package}/modules ${cfg.dataDir}/modules

        # Create config dir
        mkdir -m 0700 -p ${configDir}
        rm -f ${configDir}/elasticsearch.yml
        cp ${elasticsearchYml} ${configDir}/elasticsearch.yml

        rm -f "${configDir}/logging.yml"
        rm -f ${configDir}/${loggingConfigFilename}
        cp ${loggingConfigFile} ${configDir}/${loggingConfigFilename}
        mkdir -p ${configDir}/scripts

        rm -f ${configDir}/jvm.options
        cp ${cfg.package}/config/jvm.options ${configDir}/jvm.options

        # Create log dir
        mkdir -m 0700 -p ${cfg.dataDir}/logs

        # Start it
        exec ${cfg.package}/bin/elasticsearch ${toString cfg.extraCmdLineOptions}
      '';
      serviceConfig.KeepAlive = true;
      serviceConfig.RunAtLoad = true;
    };
  };
}
