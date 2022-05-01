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
      bindkey  "^[[H"   beginning-of-line
      bindkey  "^[[F"   end-of-line
      bindkey  "^[[3~"  delete-char
    '';
  };

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
}
