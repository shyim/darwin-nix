{ config, pkgs, lib, ... }:

{
  programs.home-manager.enable = true;

  home.username = "shyim";
  home.homeDirectory = "/Users/shyim";

  home.stateVersion = "21.05";

  nixpkgs.config.allowUnfree = true;

  programs.starship.enable = true;

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;

    enableAutosuggestions = true;
    envExtra = ''
      export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
    '';
  };

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.gpg = {
    enable = true;
    publicKeys = [{
      source = ./keys/shyim.gpg;
      trust = "ultimate";
    }];
    
    # Fixes somehow Yubikey on macOs
    scdaemonSettings = {
      disable-ccid = true;
    };
  };

  programs.git = {
    enable = true;

    signing.key = "23390FE0B21EED90CC893FE696B20A0B8A70E90A";
    signing.signByDefault = true;

    userEmail = "s.sayakci@shopware.com";
    userName = "Soner Sayakci";

    extraConfig = {
      commit.gpgsign = true;
      push.default = "current";
      fetch.prune = true;
      pull.rebase = true;
      init.defaultBranch = "main";
    };

    ignores = [
      ".DS_Store"
      ".AppleDouble"
      ".LSOverride"

      "._*"

      ".DocumentRevisions-V100"
      ".fseventsd"
      ".Spotlight-V100"
      ".TemporaryItems"
      ".Trashes"
      ".VolumeIcon.icns"
      ".com.apple.timemachine.donotpresent"
      ".AppleDB"
      ".AppleDesktop"
      "Network Trash Folder"
      "Temporary Items"
      ".apdisk"
    ];
  };

  home.file = {
    ".gnupg/gpg-agent.conf".text = ''
      enable-ssh-support
      pinentry-program ${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac
    ''; 
  };
}
