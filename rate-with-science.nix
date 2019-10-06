{ config, lib, pkgs, ... }:
let
rws = pkgs.callPackage ./pkgs/rws.nix {};
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
      ExecStart = "${rws}/bin/ratewithscience";
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
      server_name ratewith.science ratewithscience.thume.ca ratewithscience.thume.net;
      root ${rws}/public;
      listen 80;
      keepalive_timeout 20;
      index index.html;
      location / {
        try_files $uri $uri/index.html @app;
      }
      location @app {
        proxy_set_header Host $host;
        proxy_redirect off;
        proxy_pass http://localhost:5000;
      }
    }
  '';

  networking.firewall.allowedTCPPorts = [80 5000];
}
