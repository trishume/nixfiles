{ config, pkgs, ... }:
let
  netdata = pkgs.callPackage ./pkgs/netdata.nix {};
  netdataConf = ./config/netdata.conf;
  netdataDir = "/var/lib/netdata";
in
{
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

  services.nginx.httpConfig = ''
    server {
      server_name netdata.thume.net;
      location / {
        proxy_set_header Host $http_host;
        proxy_redirect off;
        proxy_pass http://127.0.0.1:19999;
      }
    }
  '';

  networking.firewall.allowedTCPPorts = [19999];
}
