{ config, pkgs, lib, ... }:

{
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
}
