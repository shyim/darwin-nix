{ pkgs, ... }:
{
  imports = [
    <home-manager/nix-darwin>

    ./modules/mysql
    ./modules/blackfire
    ./modules/php-fpm
    ./modules/caddy

    ./packages.nix
    ./services.nix
    ./secrets.nix
  ];

  nixpkgs.overlays = [ (import ./overrides.nix) ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;
  nix.extraOptions = ''
      experimental-features = nix-command flakes
  '';

  programs.zsh.enable = true;
}
