{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    nixpkgs-fmt
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
    minio
    redis
    mysql80
    git
    htop
    jq
    tree
    custom-php81
    tmux
    custom-php81.packages.composer
    custom-php81.packages.php-cs-fixer
    wget
    git-crypt
    go_1_18
    nodejs-16_x
    platformsh
    fd
    hcloud
    rbw
    rnix-lsp
    yarn
    mailhog
  ];
}
