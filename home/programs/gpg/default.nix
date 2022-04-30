{ config, pkgs, lib, ... }:

{
  programs.gpg = {
    enable = true;
    publicKeys = [{
      source = ./shyim.gpg;
      trust = "ultimate";
    }];

    # Fixes somehow Yubikey on macOs
    scdaemonSettings = { disable-ccid = true; };
  };

  home.file = {
    ".gnupg/gpg-agent.conf".text = ''
      enable-ssh-support
      pinentry-program ${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac
    '';
  };
}
