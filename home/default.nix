{ config, pkgs, lib, ... }:

{
  imports = [
    ./modules/rclone
    ./programs
  ];

  programs.home-manager.enable = true;

  home.stateVersion = "21.11";
  home.username = "shyim";
  home.homeDirectory = "/Users/shyim";
}
