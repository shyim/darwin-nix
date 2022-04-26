{ pkgs, ... }: {
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
  services.caddy.virtualHosts."http://localhost:8000" = {
    extraConfig = ''
      root * /Users/shyim/Code/sw6/public
      php_fastcgi unix//tmp/php81.sock
      encode gzip
      file_server
    '';
  };

  services.phpfpm.pools.php81 = {
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
}
