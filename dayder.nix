{ config, pkgs, ... }:
let
dayder = pkgs.callPackage ./pkgs/dayder.nix {};
in
{
  environment.systemPackages = [ dayder ];

  users.extraUsers.dayder = {
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
      listen 80;
      gzip on;
      gzip_types application/octet-stream;
      location / {
        proxy_set_header Host $host;
        proxy_redirect off;
        proxy_pass http://localhost:8080;
      }
    }
  '';

  networking.firewall.allowedTCPPorts = [8080];
}
