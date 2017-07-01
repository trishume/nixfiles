{ config, lib, pkgs, ... }:
let
wikidata = pkgs.fetchzip {
  url = "http://thume.net/bigdownloads/wikidata.zip";
  sha256 = "0h42qd2486j4v1m1xnjdgdy6n06fa4a8yknl0325qsr6p50ld3ik";
};
vibed = pkgs.stdenv.mkDerivation rec {
  name = "vibe.d";
  builder = ./scripts/vibed-builder.sh;

  dmd = pkgs.dmd;
  libevent = pkgs.libevent;

  src = pkgs.fetchFromGitHub {
    owner = "rejectedsoftware";
    repo = "vibe.d";
    rev = "v0.7.27";
    sha256 = "0bp695yxjxwhz9z7cvm3xjv0r95xz5kdqvd7gbi8p8p8r1xa1syd";
  };
  libeventd = pkgs.fetchFromGitHub {
    owner = "D-Programming-Deimos";
    repo = "libevent";
    rev = "6b7d0c9d26b88eaf94fc9cd04a11eba8fc77a0d1";
    sha256 = "1qvnh15ci8p8syvwwvv29dlqflq4c7sa5syc9sglssb3bm06zm70";
  };
  dmdpath = "${src}/source:${libeventd}";
};
rws = pkgs.stdenv.mkDerivation rec {
  name = "ratewithscience";
  src = pkgs.fetchFromGitHub {
    owner = "trishume";
    repo = "ratewithscience";
    rev = "b8bd8a85cb6b4f4cf31ce2d85939c8ab7be08c1a";
    sha256 = "1dnwbgqaxn8x08yfzsb7a3kp3s8m5s9msysg0gx9iws96i9rqw8r";
  };

  builder = ./scripts/rws-builder.sh;

  dmd = pkgs.dmd;
  sqlite = pkgs.sqlite.out;
  libevent = pkgs.libevent.out;
  inherit wikidata;
  inherit vibed;

  d2sqlite3 = pkgs.fetchFromGitHub {
    owner = "biozic";
    repo = "d2sqlite3";
    rev = "v0.9.7";
    sha256 = "0rn6l7d0hj75yd50qwijn3irzkyk88vpqzmi5l4h6gimgi2a0vs6";
  };
  gfm = pkgs.fetchFromGitHub {
    owner = "d-gamedev-team";
    repo = "gfm";
    rev = "v3.0.11";
    sha256 = "1z5zvyabpdl6hs7lhrd8d3faczw9rjj38hh07vsd00pvsgygl3v6";
  };
  dmdpath = "${src}/source:${vibed}/source:${gfm}/core:${d2sqlite3}/source";
};
in
{
  users.extraUsers = lib.singleton {
    name = "ratews";
    description = "Rate With Science server user";
    uid = 200000;
    home = "${rws}";
    isSystemUser = true;
  };
  systemd.services.ratews = {
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      WorkingDirectory= "${rws}";
      ExecStart = "${rws}/ratewithscience";
      User = "ratews";
      Restart = "on-failure";
    };
  };

  # Since the site is used infrequently but when it is, it needs to quickly traverse
  # 500MB of memory in random order, getting swapped out is deadly and basically
  # makes it unusable. Make the system try very hard not to swap things out for this reason.
  boot.kernel.sysctl = { "vm.swappiness" = 0; };

  services.nginx.httpConfig = ''
    server {
      server_name ratewith.science;
      root ${rws}/public;
      listen 80;
      keepalive_timeout 20;
      index index.html;
      location / {
        try_files $uri $uri/index.html @app;
      }
      location @app {
        proxy_set_header Host $http_host;
        proxy_redirect off;
        proxy_pass http://127.0.0.1:5000;
      }
    }
  '';

  networking.firewall.allowedTCPPorts = [80 5000];
}
