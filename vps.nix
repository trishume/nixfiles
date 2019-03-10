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
in
{
  imports = [
    ./rate-with-science.nix
    ./hound.nix
    ./dayder.nix
    ./hnblogs.nix
    # ./netdata.nix
    # ./kibana.nix
  ];
  environment.systemPackages = with pkgs; [
    tmux
    weechat
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
      location /misc/ {
        alias /home/tristan/sites/;
      }
    }
    '';
  };

  services.syncthing = {
    enable = true;
    dataDir = "/home/tristan/.syncthing";
    user = "tristan";
  };

  # MQTT server for my LED strip
  services.mosquitto = {
    enable = true;
    host = "0.0.0.0";
    # Yes the passwords are public and you have the means to mess with my lighting.
    # Please don't though, it will make me rethink publishing my Nix files and I think
    # it is beneficial to have them publicly available for reference by others.
    users.lightstrip = {
      acl = ["topic readwrite lightstrip/#"];
      password = "dumbpublic94732";
    };
    users.lightserver = {
      acl = ["topic readwrite lightstrip/#" "topic readwrite lightserver/#"];
      password = "dumbpublic25487";
    };
  };

  networking.firewall.allowedTCPPorts = [9001 22000 1883];
  networking.firewall.allowedUDPPorts = [21027];
}
