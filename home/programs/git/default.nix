{ config, pkgs, lib, ... }:

{
  programs.git = {
    enable = true;

    delta.enable = true;

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
}
