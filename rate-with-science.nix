{ config, lib, pkgs, ... }:
let
wikidata = pkgs.fetchzip {
  url = "http://thume.net/bigdownloads/wikidata.zip";
  sha256 = "062fgwbfgkdja2q1f08kmdhpzgc124k0xpkqd39d1zc6bc7cbsx2";
};
jester = pkgs.fetchFromGitHub {
  owner = "dom96";
  repo = "jester";
  rev = "fd90a84ecfe12f37b75afc50691ab43cdb7c278f";
  sha256 = "1dgv3s7bgb0901yc9zyv8vj65z74b1d7z5cihgvmik5vimz7bzm6";
};
rws = pkgs.stdenv.mkDerivation {
  name = "ratewithscience";
  builder = ./scripts/rws-builder.sh;
  src = pkgs.fetchFromGitHub {
    owner = "trishume";
    repo = "ratewithscience";
    rev = "bbe2982ea3b4bd336375cb77730becbb68046bc3";
    sha256 = "1g7r07di00msszm03cb9i5i44n7mqxk6453smz7cfvmakfss9vv3";
  };

  libPath = with pkgs; stdenv.lib.makeLibraryPath [ stdenv.cc.cc sqlite glibc ];

  nim = pkgs.nim;
  sqlite = pkgs.sqlite;
  inherit jester;
  inherit wikidata;
};
utilitysite = pkgs.stdenv.mkDerivation {
  name = "utilitysite";
  builder = ./scripts/setup-downloads.sh;
  wikidata = pkgs.fetchurl {
    url = "http://thume.net/bigdownloads/wikidata.zip";
    sha256 = "1z2c4f16ln7j0bkqfmhclzqihqk8viy5sn8mv5kzb3rp5p1jmnjh";
  };
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
      ExecStart = "${rws}/server";
      User = "ratews";
      Restart = "on-failure";
    };
  };


  services.nginx = {
    enable = true;
    httpConfig = ''
    sendfile on;
    tcp_nopush on;
    server {
      server_name thume.net;
      listen 80;
      keepalive_timeout 20;

      index index.html;
      root ${utilitysite};

      location /stashline {
        rewrite ^/stashline/?(.*)$ http://thume.ca/stashline/$1 permanent;
      }
      location /bigdownloads/ {
        autoindex on;
      }
    }

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
  };

  networking.firewall.allowedTCPPorts = [80 5000];
}
