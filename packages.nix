{ pkgs, ... }:

let
  blackfirePhpExt = pkgs.callPackage ./pkgs/blackfire-probe.nix { php = pkgs.php81; };
  php = pkgs.php81.buildEnv {
    extensions = { all, enabled }: with all; enabled ++ [ redis blackfirePhpExt pdo iconv ];
    extraConfig = ''
      memory_limit = 2G
      pdo_mysql.default_socket=/tmp/mysql.sock
      mysqli.default_socket=/tmp/mysql.sock
      blackfire.agent_socket = "tcp://127.0.0.1:8307";
    '';
  };
in {
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    nixfmt
    (neovim.override {
      vimAlias = true;
      configure = {
        packages.myPlugins = with vimPlugins; {
          start = [ vim-lastplace vim-nix ];
          opt = [ ];
        };
        customRC = ''
          " your custom vimrc
          set nocompatible
          set backspace=indent,eol,start
          " ...
        '';
      };
    })
    redis
    mysql80

    git
    htop
    jq
    tree
    symfony-cli
    php
    tmux
    php.packages.composer
    wget
    git-crypt
    go_1_18
  ];
}
