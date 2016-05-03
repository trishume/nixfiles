{ config, pkgs, ... }:
let
dayder = pkgs.callPackage ./pkgs/dayder.nix {};
in
{
  environment.systemPackages = [ dayder ];

  users.extraUsers = pkgs.lib.singleton {
    name = "dayder";
    description = "Dayder server user";
    uid = 200005;
  };

  systemd.services.dayder = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${dayder}/bin/dayder";
      User = "dayder";
      Restart = "on-failure";
      WorkingDirectory = "${dayder}";
    };
  };

  services.nginx.httpConfig = ''
    server {
      server_name dayder.thume.net dayder.thume.ca;
      gzip on;
      gzip_types application/octet-stream;
      location / {
        proxy_set_header Host $http_host;
        proxy_redirect off;
        proxy_pass http://127.0.0.1:8080;
      }
    }
  '';

  networking.firewall.allowedTCPPorts = [8080];
}
