{ config, pkgs, ... }:
let
wikidata = fetchzip {
  url = "http://thume.net/bigdownloads/wikidata.zip";
  sha256 = "062fgwbfgkdja2q1f08kmdhpzgc124k0xpkqd39d1zc6bc7cbsx2";
};
jester = fetchFromGitHub {
  owner = "dom96";
  repo = "jester";
  rev = "fd90a84ecfe12f37b75afc50691ab43cdb7c278f";
  sha256 = "b06bf65c0166a93d72d8bf01c65cf7a2fb5aca618ab29361c217619c6af8d71c";
};
rws = stdenv.mkDerivation {
  name = "ratewithscience";
  builder = ./scripts/rws-builder.sh;
  src = fetchFromGitHub {
    owner = "trishume";
    repo = "ratewithscience";
    rev = "bbe2982ea3b4bd336375cb77730becbb68046bc3";
    sha256 = "91187a299d62d43446568e3fe28b3a3d7ecd07f08304097f61a2c5caeb8327e4";
  };

  nim = pkgs.nim;
  inherit jester;
  inherit wikidata;
};
in
{
  environment.systemPackages = with pkgs; [
    nim rws
   ];
}
