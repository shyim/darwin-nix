{ pkgs, lib, config,  ... }: {
  services.redis.enable = true;
  services.redis.dataDir = null;  

  services.mysql.enable = true;

  programs.gnupg.agent.enable = true;
  programs.gnupg.agent.enableSSHSupport = true;

  users.users.shyim = {
    name = "shyim";
    home = "/Users/shyim";
  };

  home-manager.users.shyim = import ./home.nix;

  services.blackfire.enable = true;

  services.caddy.enable = true;

  services.phpfpm.pools.php81 = {
    phpPackage = pkgs.custom-php81;
    settings = {
      "pm" = "dynamic";
      "pm.max_children" = 32;
      "pm.max_requests" = 500;
      "pm.start_servers" = 2;
      "pm.min_spare_servers" = 2;
      "pm.max_spare_servers" = 5;
      "php_admin_value[error_log]" = "stderr";
      "php_admin_flag[log_errors]" = true;
      "catch_workers_output" = true;
    };
  };

  services.caddy.virtualHosts."http://sw6.dev.localhost" = {
    extraConfig = ''
      root * /Users/shyim/Code/sw6/public
      php_fastcgi unix/${config.services.phpfpm.pools.php81.socket}
      encode gzip
      file_server
    '';
  };

  services.caddy.virtualHosts."http://flex.dev.localhost" = {
    extraConfig = ''
      root * /Users/shyim/Code/flex/public
      php_fastcgi unix/${config.services.phpfpm.pools.php81.socket}
      encode gzip
      file_server
    '';
  };

  services.elasticsearch.enable = true;
  services.elasticsearch.package = pkgs.elasticsearch7;
  services.elasticsearch.extraConf = ''
  xpack.ml.enabled: false
  '';
}
