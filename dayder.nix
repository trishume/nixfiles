{ config, pkgs, ... }:
let
dayder = pkgs.callPackage ./pkgs/dayder.nix {};
in
{
  # environment.systemPackages = [ dayder ];

  # users.extraUsers = pkgs.lib.singleton {
  #   name = "dayder";
  #   description = "Dayder server user";
  #   uid = 200005;
  # };

  # systemd.services.dayder = {
  #   wantedBy = [ "multi-user.target" ];
  #   after = [ "network.target" ];
  #   serviceConfig = {
  #     ExecStart = "${dayder}/bin/dayder";
  #     User = "dayder";
  #     Restart = "on-failure";
  #   };
  # };

  networking.firewall.allowedTCPPorts = [8080];
}
