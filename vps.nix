{ config, pkgs, ... }:

{
  services = {
    znc = {
      enable = true;
      mutable = true;
    };

    networking.firewall.allowedTCPPorts = [5000];
  };
}
