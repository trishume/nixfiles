{ config, pkgs, ... }:
let
hnblogs = pkgs.callPackage ./pkgs/hnblogs.nix {};
in
{
  environment.systemPackages = [ hnblogs ];

  users.extraUsers = pkgs.lib.singleton {
    name = "hnblogs";
    description = "HNBlogs server user";
    uid = 200006;
  };

  systemd.services.hnblogs = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${hnblogs}/bin/hnblogs";
      User = "hnblogs";
      Restart = "on-failure";
      # WorkingDirectory = "${hnblogs}";
    };
  };

  services.nginx.httpConfig = ''
    server {
      server_name hnblogs.thume.net hnblogs.thume.ca;
      listen 80;
      gzip on;
      gzip_types application/octet-stream;
      location / {
        proxy_set_header Host $http_host;
        proxy_redirect off;
        proxy_pass http://localhost:4567;
      }
    }
  '';

  # networking.firewall.allowedTCPPorts = [4567];
}
