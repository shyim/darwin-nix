{ lib
, stdenv
, fetchurl
, makeWrapper
, jre_headless
, util-linux, gnugrep, coreutils
, autoPatchelfHook
, zlib
, groff
}:

stdenv.mkDerivation (rec {
  pname = "awscli2";
  version = "2.7.9";

  src = fetchurl {
    url = "https://cdn.shyim.de/aws-cli-arm64-2.7.9.tar.gz";
    sha256 = "sha256-/a8eGXaEuNHXNgsPK96ugU44XMTnIrkmFLp47PvrgSo=";
  };
  sourceRoot = ".";

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    cp -R * $out
    makeWrapper $out/aws $out/bin/aws \
      --prefix PATH : ${lib.makeBinPath [ groff ]}
  '';

  meta = {
    description = "AWS CLI v2";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ shyim ];
  };
})