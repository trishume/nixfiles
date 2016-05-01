{ stdenv, fetchFromGitHub, rustPlatform }:

with rustPlatform;

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

  postFixup = ''
    mkdir -p $out/btsf
    ln -s $src/btsf/* $out/btsf/
    ln -s $src/public $out/public
  '';

  meta = with stdenv.lib; {
    description = "Spurious correlation finder web app";
    homepage = https://github.com/trishume/dayder;
    license = stdenv.lib.licenses.mit;
  };
}
