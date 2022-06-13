self: super: let 
  php82 = super.pkgs.callPackage ./pkgs/php82 {};   
in {
  custom-php81 = php82.buildEnv {
    extensions = { all, enabled }: with all; enabled ++ [ redis ];
    extraConfig = ''
      memory_limit = 2G
      pdo_mysql.default_socket=/tmp/mysql.sock
      mysqli.default_socket=/tmp/mysql.sock
      blackfire.agent_socket = "tcp://127.0.0.1:8307";
      realpath_cache_ttl=3600
      session.gc_probability=0
      display_errors = On
      error_reporting = E_ALL
    '';
  };
}
