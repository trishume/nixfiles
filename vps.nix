{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    znc
   ];

  services = {
    znc = {
      enable = true;
      # Bug means the default dir has extra slash
      dataDir = "/var/lib/znc";

      confOptions = {
        userName = "thume";
        nick = "thume";
        # Cludge using the pass block as general user config
        passBlock = ''
          Pass       = sha256#5da3ad0154d4c0e4d3e11ddbb62a7b6c650d95f41faec72e06c1e72cfc431915#4638!Jgyf6*d4cUm!sxU#
          <Network freenode>
            LoadModule = simple_away
            Server     = irc.freenode.net +6667
            <Chan #nixos>
            </Chan>
          </Network>
        '';
      };
    };
  };
  networking.firewall.allowedTCPPorts = [5000];
}
