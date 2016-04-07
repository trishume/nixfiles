{ stdenv, fetchurl, pkgconfig, git, coreutils, which, zlib, makeWrapper,
  iproute, gawk, netcat, procps, strace, utillinux, time, libcap, gnugrep, gnused, attr, cpio, acl }:

stdenv.mkDerivation {
  name = "netdata-1.0.0";
  src = fetchurl {
    url = https://firehol.org/download/netdata/releases/v1.0.0/netdata-1.0.0.tar.xz;
    sha256 = "114rynka9kpas9mr8ixdydqqqwxaiqi7flj62s2z0w0n8bk2c02w";
  };
  buildInputs = [ pkgconfig zlib makeWrapper ];
  postFixup = ''
    wrapProgram $out/bin/netdata \
      --set SSL_CERT_FILE "/etc/ssl/certs/ca-certificates.crt" \
      --prefix PATH : "${iproute}/bin:${git}/bin:${coreutils}/bin:${which}/bin:${gawk}/bin:${netcat}/bin:${procps}/bin:${strace}/bin:${utillinux}/bin:${time}/bin:${libcap}/bin:${gnugrep}/bin:${gnused}/bin:${attr}/bin:${cpio}/bin:${acl}/bin:"
  '';
}
