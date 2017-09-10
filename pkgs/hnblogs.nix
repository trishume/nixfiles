{ stdenv, makeWrapper, lib, bundlerEnv, fetchFromGitHub, ruby, curl }:
let
src = fetchFromGitHub {
  owner = "trishume";
  repo = "hnblogs";
  rev = "50a80950d6676ef446922f804e0d734f9ae0e493";
  sha256 = "185vl3g6mzdpfhz0rikhkg7xnhil171igqhpwgaaxxp8yvbf1779";
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
