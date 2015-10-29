{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    znc
   ];

  services = {
    znc = {
      enable = true;
      mutable = true;
      # Bug means the default dir has extra slash
      dataDir = "/var/lib/znc";
    };
  };
  networking.firewall.allowedTCPPorts = [5000];
}
