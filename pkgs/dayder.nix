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
  version = "2.0";

  depsSha256 = "12hn1xfphfgd6n9hi5m1cwxlnxamk26m0xak6bcbxg025rlj7q0z";

  src = fetchFromGitHub {
    owner = "trishume";
    repo = "dayder";
    rev = "v${version}";
    sha256 = "1sj97chhjwpxvchvc8kh39nald7fadpf28gmvarisxw5jhxnlyi0";
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
