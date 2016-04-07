{ config, pkgs, ... }:
let
utilitysite = pkgs.stdenv.mkDerivation {
  name = "utilitysite";
  builder = ./scripts/setup-downloads.sh;
  wikidata = pkgs.fetchurl {
    url = "http://thume.net/bigdownloads/wikidata.zip";
    sha256 = "1ygmn04swa3ykq83d1qw5wr8dzpp2c8yvcfi7ns047b4pv61j42j";
  };
  #wikidata = pkgs.stdenv.mkDerivation {
  #  name = "wikidata.zip";
  #  outputHashMode = "recursive";
  #  outputHashAlgo = "sha256";
  #  outputHash = "1nzxqd3bvwr1c2jma4vm7s8v5pqnhl2ygzzzk9fim9rx1sv1fpl2";
  #};
};
netdata = pkgs.callPackage ./pkgs/netdata.nix {};
netdataConf = ./config/netdata.conf;
netdataDir = "/var/lib/netdata";
in
{
  imports = [
    ./rate-with-science.nix
    ./hound.nix
    ./dayder.nix
    # ./kibana.nix
  ];
  environment.systemPackages = with pkgs; [
    tmux
    weechat
    netdata
   ];

  # See https://weechat.org/files/doc/devel/weechat_quickstart.en.html for
  # manual setup. Weechat uses a weird mutable config file system that
  # doesn't play well with NixOS immutability
  #
  # Also run the following to set up the relay:
  # /set relay.network.password yourpassword
  # /relay add weechat 9001
  systemd.services.ircSession = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Type = "forking";
      User = "tristan";
      ExecStart = ''${pkgs.tmux}/bin/tmux new-session -d -s irc -n irc ${pkgs.weechat}/bin/weechat'';
      ExecStop = ''${pkgs.tmux}/bin/tmux kill-session -t irc'';
    };
  };

  users.extraGroups.netdata.gid = 220008;
  users.extraUsers = pkgs.lib.singleton {
    name = "netdata";
    description = "Netdata server user";
    uid = 200008;
  };
  systemd.services.netdata = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    preStart =
      ''
      mkdir -p ${netdataDir}/logs
      cp -r ${netdata}/share/netdata/web ${netdataDir}/web
      chmod -R 700 ${netdataDir}
      chown -R netdata:netdata ${netdataDir}
      '';
    serviceConfig = {
      Type = "forking";
      ExecStart = "${netdata}/bin/netdata -c ${netdataConf} -u netdata";
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
      server_name netdata.thume.net;
      location / {
        proxy_set_header Host $http_host;
        proxy_redirect off;
        proxy_pass http://127.0.0.1:19999;
      }
    }
    '';
  };

  networking.firewall.allowedTCPPorts = [9001 19999];
}
