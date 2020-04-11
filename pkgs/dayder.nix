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
  version = "2.2.2";

  cargoSha256 = "10xgka90mm6mfhaag5x4v9jm2a6riq129sfhzl14p88lvgyw4f9k";
  verifyCargoDeps = true;

  src = fetchFromGitHub {
    owner = "trishume";
    repo = "dayder";
    rev = "v${version}";
    sha256 = "0f72swcj1ny843cy8wdw8wp0gxv913j0zyqzidazc66hvj4jqi26";
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
