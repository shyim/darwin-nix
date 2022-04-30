{ config, pkgs, lib, ... }:

{
    imports = [
        ./rclone
        ./gpg
        ./git
        ./shell
    ];
}