{ stdenv, fetchFromGitHub, fetchzip, rustPlatform, sqlite }:

with rustPlatform;
let
wikidata = fetchzip {
  url = "http://thume.net/bigdownloads/wikidata.zip";
  sha256 = "0h42qd2486j4v1m1xnjdgdy6n06fa4a8yknl0325qsr6p50ld3ik";
};
in
buildRustPackage rec {
  name = "rws-${version}";
  version = "4.0";

  cargoSha256 = "1j5nxqpkwnbc3d7i73zgazgalhzcwqr10smryhf63w5bb3dgdjv7";
  verifyCargoDeps = true;

  src = fetchFromGitHub {
    owner = "trishume";
    repo = "ratewithscience";
    rev = "v${version}";
    sha256 = "0syy4j3nhdla45rrg172ik8awkvir6q2kxxvfn4vg9j7z4fh2knw";
  };

  buildInputs = [ sqlite ];
  # Don't run tests because we haven't linked in the database
  checkPhase = null;

  inherit wikidata;
  postFixup = ''
    ln -s $wikidata $out/data
    ln -s $src/public $out/public
  '';

  meta = with stdenv.lib; {
    description = "Find paths in Wikipedia";
    homepage = https://github.com/trishume/ratewithscience;
    license = stdenv.lib.licenses.mit;
  };
}
