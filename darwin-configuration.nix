{ pkgs, ... }:
{
  imports = [
    <home-manager/nix-darwin>

    ./modules/mysql

    ./packages.nix
    ./services.nix
  ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;

  programs.zsh.enable = true;
}
