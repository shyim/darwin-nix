{ pkgs, ... }: 

let 
    php = pkgs.php81.buildEnv {
        extensions = { all, enabled }: with all; enabled ++ [ redis ];
        extraConfig = ''
        memory_limit = 2G
        pdo_mysql.default_socket=/tmp/mysql.sock
        mysqli.default_socket=/tmp/mysql.sock
        '';
    };
in {

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
  ];
}
