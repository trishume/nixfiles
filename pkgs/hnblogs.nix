{ stdenv, makeWrapper, lib, bundlerEnv, fetchFromGitHub, ruby, curl }:
let
src = fetchFromGitHub {
  owner = "trishume";
  repo = "hnblogs";
  rev = "561633306cd14f30315786647bea84c6c8addd27";
  sha256 = "0s95nnvnbq8ixip767yhwx728q7p0ab5bnf7w9pfmkpzbrymfafs";
};
version = "1.0";
env = bundlerEnv rec {
  name = "hnblogs-${version}-gems";

  inherit ruby;
  inherit version;
  # expects Gemfile, Gemfile.lock and gemset.nix in the same directory
  gemdir = src;
};
in
stdenv.mkDerivation rec {
  name = "hnblogs-${version}";

  inherit version;
  inherit env;

  runscript = ./hnblogs.sh;

  buildInputs = [ makeWrapper ];

  phases = ["installPhase"];

  installPhase = ''
    mkdir -p $out/bin
    cp ${runscript} $out/bin/hnblogs-unwrapped.sh
    chmod +x $out/bin/hnblogs-unwrapped.sh
    makeWrapper $out/bin/hnblogs-unwrapped.sh $out/bin/hnblogs \
      --prefix LD_PRELOAD : "${stdenv.lib.makeLibraryPath [ curl ]}/libcurl.so.4" \
      --set HNBLOGS '${src}' \
      --set PATH '"${ruby}/bin/:${env}/bin/:$PATH"'
  '';

  # buildInputs = [ env.wrapper ];

  # buildCommand = ''
  #   mkdir -p $out/bin
  #   install -D -m755 $runscript $out/bin/hnblogs
  #   patchShebangs $out/bin/hnblogs
  # '';

  meta = with lib; {
    description = "RSS feed for HN comments";
    homepage    = https://github.com/trishume/hnblogs;
    license     = with licenses; apache;
    platforms   = platforms.unix;
  };
}
