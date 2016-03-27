{ stdenv, fetchFromGitHub, rustPlatform }:

with rustPlatform;

buildRustPackage rec {
  name = "dayder-${version}";
  version = "1.0";

  depsSha256 = "03jap7myf85xgx9270sws8x57nl04a1wx8szrk9qx24s9vnnjcnh";

  src = fetchFromGitHub {
    owner = "trishume";
    repo = "dayder";
    rev = "v${version}";
    sha256 = "1m8jk8bg94dq4qkh3s6ipmy6y060wdhrp2l3rjzl57z20l8c1y6z";
  };

  meta = with stdenv.lib; {
    description = "Spurious correlation finder web app";
    homepage = https://github.com/trishume/dayder;
    license = stdenv.lib.licenses.mit;
  };
}
