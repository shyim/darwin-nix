{ pkgs, ... }:

{
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
    custom-php81
    tmux
    custom-php81.packages.composer
    wget
    git-crypt
    go_1_18
    nodejs-16_x
    platformsh
    fd
    hcloud
  ];
}
