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
  version = "2.2.1";

  cargoSha256 = "0aq9g2pwxn14nf41bqz4796rzylsh1azilir7c667j6ya28pxc7y";
  verifyCargoDeps = true;

  src = fetchFromGitHub {
    owner = "trishume";
    repo = "dayder";
    rev = "v${version}";
    sha256 = "116xz5fya970nzp9pg9f30an1llwyim831mnm4277483hjvc0yi6";
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
