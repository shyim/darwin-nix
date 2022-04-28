self: super: {
  custom-php81 = let blackfirePhpExt = super.pkgs.callPackage ./pkgs/blackfire-probe.nix { php = super.pkgs.php81; }; in super.pkgs.php81.buildEnv {
    extensions = { all, enabled }: with all; enabled ++ [ redis blackfirePhpExt ];
    extraConfig = ''
      memory_limit = 2G
      pdo_mysql.default_socket=/tmp/mysql.sock
      mysqli.default_socket=/tmp/mysql.sock
      blackfire.agent_socket = "tcp://127.0.0.1:8307";
    '';
  };
  ansible = super.ansible.overrideAttrs (old: rec {
    propagatedBuildInputs = old.propagatedBuildInputs ++ [
      super.pkgs.python39Packages.jmespath
      super.pkgs.gnutar
    ];
  });
}