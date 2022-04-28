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

  version = "1.77.0";
  zts = if php.ztsSupport then "zts" else "normal";
  sources = {
    "x86_64-linux" = {
      url = "https://packages.blackfire.io/debian/pool/any/main/b/blackfire-php/blackfire-php_${version}_amd64.deb";
      sha256 = "MsmQJSEr1GOqzw2jq77ZJn13AYqMIGY+yez6dMxyOMo=";
    };
    "i686-linux" = {
      url = "https://packages.blackfire.io/debian/pool/any/main/b/blackfire-php/blackfire-php_${version}_i386.deb";
      sha256 = "MsmQJSEr1GOqzw2jq77ZJn13AYqMIGY+yez6dMxyOMo=";
    };
    "aarch64-linux" = {
      url = "https://packages.blackfire.io/debian/pool/any/main/b/blackfire-php/blackfire-php_${version}_arm64.deb";
      sha256 = "MsmQJSEr1GOqzw2jq77ZJn13AYqMIGY+yez6dMxyOMo=";
    };
    "aarch64-darwin" = {
      url = "https://packages.blackfire.io/homebrew/blackfire-php_${version}-darwin_arm64-php${builtins.replaceStrings ["."] [""] phpMajor}${lib.optionalString php.ztsSupport "-zts"}.tar.gz";
      sha256 = {
        "7.4" = {
          normal = "bca387fb23c3c9ff0ac57d03a049eba761d761f0c0c550fbd3c319ad118c1049";
          zts = "72978eb434613c0df9bad6a2f06d43a2cbaa85fefa862aafc1ef849bd705843a";
        };
        "8.0" = {
          normal = "bfa3c3d7e1a1beda2ad70cc05f0aa2f5e9720bdfcdc335f410376d42d09f78be";
          zts = "0eab343fc5fb49c0c908f60abaa96e9a72f3e2407b7043a755b0c0090d36b24a";
        };
        "8.1" = {
          normal = "9826756af0bc16ca9874660d7a97aa5a048ada4a95a351345638687f175a4b29";
          zts = "ce589a33655b683120341af91137b519d60dc93672e6d7bdd8b79d662a25c7ff";
        };
      };
    };
    "x86_64-darwin" = {
      url = "https://packages.blackfire.io/homebrew/blackfire-php_${version}-darwin_arm64-php${builtins.replaceStrings ["."] [""] phpMajor}${lib.optionalString php.ztsSupport "-zts"}.tar.gz";
      sha256 = {
        "7.4" = {
          normal = "9cbb2ba519d1f73a3777f6b4f9314194d70079b927a4141cd74d72b2a3ecf9d5";
          zts = "a3b47cce68483ad88d0d2f127b70e883e727f47c931f34b88eab9777319040e5";
        };
        "8.0" = {
          normal = "3dedbf18d0e24b90ee49709f7ced23a39751974aa48754600552f72732f05644";
          zts = "ceeed081a29b04d4246f2edb2eff8d28b4886bbf545cc38d11fd7bd443beb8d1";
        };
        "8.1" = {
          normal = "dd23a52de2c233872b598e94fbfce6b5698d620da3d070bfdc55829828bb94ea";
          zts = "186f2cf8f7742ba484533455f7a05ada661f2e040cb8637346852d9b3f66d0d6";
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
    platforms = [ "x86_64-linux" "aarch64-linux" "i686-linux" "x86_64-darwin" "aarch64-darwin" ];
  };
}
