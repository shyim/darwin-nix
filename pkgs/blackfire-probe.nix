{ stdenv
, lib
, fetchurl
, dpkg
, autoPatchelfHook
, php
, writeShellScript
, curl
, jq
, common-updater-scripts
}:

let
  phpMajor = lib.versions.majorMinor php.version;
  soFile = {
    "7.4" = "blackfire-20190902";
    "8.0" = "blackfire-20200930";
    "8.1" = "blackfire-20210902";
  }.${phpMajor} or (throw "Unsupported PHP version.");

  version = "1.75.0";
  zts = if php.ztsSupport then "zts" else "normal";
  sources = {
    "x86_64-linux" = {
      url = "https://packages.blackfire.io/debian/pool/any/main/b/blackfire-php/blackfire-php_${version}_amd64.deb";
      sha256 = "MsmQJSEr1GOqzw2jq77ZJn13AYqMIGY+yez6dMxyOMo=";
    };
    "aarch64-darwin" = {
      url = "https://packages.blackfire.io/homebrew/blackfire-php_${version}-darwin_arm64-php${builtins.replaceStrings ["."] [""] phpMajor}${lib.optionalString php.ztsSupport "-zts"}.tar.gz";
      sha256 = {
        "7.4" = {
          normal = "288cb32b4048e9e9410147c8d4191086b043bd379799b7b763e67b078df23ef6";
          zts = "3f527914e22609db15c5982be698c01d584e78f0ac0c6b0fe7e4dcc5c42fde5c";
        };
        "8.0" = {
          normal = "660b8c589b0aa8723e7a4a059fcb06465968cf0fbf1036a78546d0b1aa2d95da";
          zts = "2c2a8723bf87a459b0cfb752a44fcfe7247c26ebc8bfe067618b644abb01a5cd";
        };
        "8.1" = {
          normal = "ymgxI8E+zu9Vo6V3URGv/kvYJSjrecL3bmvoPKQTLtA=";
          zts = "1905e79adea9acd03b5827e61d1616667f637d69099307eb01e71db003ab983d";
        };
      };
    };
  };
in stdenv.mkDerivation rec {
  pname = "php-blackfire";
  inherit version;

  src = fetchurl {
      url = sources.${stdenv.hostPlatform.system}.url;
      sha256 = if stdenv.isLinux then sources.${stdenv.hostPlatform.system}.sha256 else sources.${stdenv.hostPlatform.system}.sha256.${phpMajor}.${zts};
  };

  nativeBuildInputs = lib.optional stdenv.isLinux [
    dpkg
    autoPatchelfHook
  ];

  setSourceRoot = lib.optional stdenv.isDarwin "sourceRoot=`pwd`";

  unpackPhase = lib.optional stdenv.isLinux ''
    runHook preUnpack
    dpkg-deb -x $src pkg
    sourceRoot=pkg
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    if ${ lib.boolToString stdenv.isLinux }
    then
        install -D usr/lib/blackfire-php/amd64/${soFile}${lib.optionalString php.ztsSupport "-zts"}.so $out/lib/php/extensions/blackfire.so
    else
        install -D blackfire.so $out/lib/php/extensions/blackfire.so
    fi

    runHook postInstall
  '';

  passthru = {
    updateScript = writeShellScript "update-${pname}" ''
      export PATH="${lib.makeBinPath [ curl jq common-updater-scripts ]}"
      update-source-version "$UPDATE_NIX_ATTR_PATH" "$(curl https://blackfire.io/api/v1/releases | jq .probe.php --raw-output)"
    '';
  };

  meta = with lib; {
    description = "Blackfire Profiler PHP module";
    homepage = "https://blackfire.io/";
    license = licenses.unfree;
    maintainers = with maintainers; [ jtojnar shyim ];
    platforms = [ "x86_64-linux" "aarch64-darwin" ];
  };
}
