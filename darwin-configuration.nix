{ pkgs, ... }:
{
  imports = [
    <home-manager/nix-darwin>
    <nix-darwin-modules>

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

  nix.distributedBuilds = true;
  nix.buildMachines = [
    { 
      hostName = "aelia.shyim.de";
      sshUser = "root";
      system = "x86_64-linux";
      sshKey = "/Users/shyim/.nixpkgs/keys/builder.key";
    }
    { 
      hostName = "aelia.shyim.de";
      sshUser = "root";
      system = "i686-linux";
      sshKey = "/Users/shyim/.nixpkgs/keys/builder.key";
    }
    { 
      hostName = "130.162.211.118";
      sshUser = "opc";
      system = "aarch64-linux";
      sshKey = "/Users/shyim/.nixpkgs/keys/builder.key";
    }
  ];

  programs.zsh.enable = true;
}
