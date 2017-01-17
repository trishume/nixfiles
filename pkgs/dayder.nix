{ stdenv, fetchFromGitHub, fetchurl, rustPlatform }:

with rustPlatform;
let
fredData = fetchurl {
  url = "file:///home/tristan/misc/dayder/btsf/fred-small.btsf";
  sha256 = "02br8f27l1rwvwq4cvcnvqvzlk4wc2zz0cy2ii9x6j7nhy63ccqz";
};
in
buildRustPackage rec {
  name = "dayder-${version}";
  version = "2.1";

  depsSha256 = "0qhyzmfh976fpsxgrxmf7s5d29d9h9plwyf66x7lddwib8kfjp8z";

  src = fetchFromGitHub {
    owner = "trishume";
    repo = "dayder";
    rev = "v${version}";
    sha256 = "1c2m1nl0y2jacdhy2pabrz1r5vc27ydm5ljdhpfsn8mhacyk6yak";
  };


  inherit fredData;
  postFixup = ''
    mkdir -p $out/btsf
    ln -s $src/btsf/* $out/btsf/
    ln -s $fredData $out/btsf/fred-small.btsf
    ln -s $src/public $out/public
  '';

  meta = with stdenv.lib; {
    description = "Spurious correlation finder web app";
    homepage = https://github.com/trishume/dayder;
    license = stdenv.lib.licenses.mit;
  };
}
