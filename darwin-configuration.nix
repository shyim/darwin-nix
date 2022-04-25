{ pkgs, ... }:
{
  imports = [
    <home-manager/nix-darwin>

    ./modules/mysql
    ./modules/blackfire

    ./packages.nix
    ./services.nix
    ./secrets.nix
  ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;
  nix.extraOptions = ''
      experimental-features = nix-command flakes
  '';

  programs.zsh.enable = true;
}
