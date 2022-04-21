{ pkgs, ... }: {
  launchd.user.agents.redis = {
    script = ''
      if ! test -e /opt/nix/redis; then
        mkdir /opt/nix/redis
      fi
      exec ${pkgs.redis}/bin/redis-server
    '';
    serviceConfig.KeepAlive = true;
  };

  services.mysql.enable = true;

  programs.gnupg.agent.enable = true;
  programs.gnupg.agent.enableSSHSupport = true;

  users.users.shyim = {
    name = "shyim";
    home = "/Users/shyim";
  };

  home-manager.users.shyim = import ./home.nix;
}
