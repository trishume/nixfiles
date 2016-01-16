{ config, pkgs, ... }:

{
  imports = [ ./rate-with-science.nix ];
  environment.systemPackages = with pkgs; [
    znc
    weechat
   ];

  services = {
    znc = {
      #enable = true;
      enable = false;
      # Bug means the default dir has extra slash
      dataDir = "/var/lib/znc";

      confOptions = {
        port = 8832;
        userName = "thume";
        nick = "thume";
        useSSL = false;
        userModules = [ "sasl"];
        # Cludge using the pass block as general user config
        passBlock = ''
          Pass       = sha256#5da3ad0154d4c0e4d3e11ddbb62a7b6c650d95f41faec72e06c1e72cfc431915#4638!Jgyf6*d4cUm!sxU#
          <Network freenode>
            LoadModule = simple_away
            Server     = irc.freenode.net +7000
            <Chan #nixos>
            </Chan>
            <Chan #csc>
            </Chan>
            <Chan #ve3uow>
            </Chan>
            <Chan #geekhack>
            </Chan>
          </Network>
        '';
      };
    };
  };
  networking.firewall.allowedTCPPorts = [8832];
}
