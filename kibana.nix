{ config, pkgs, ... }:

{
  imports = [./modules/mykibana.nix];
  environment.systemPackages = with pkgs; [
    kibana
    elasticsearch
   ];

  services.elasticsearch = {
    enable = true;
    plugins = [pkgs.elasticsearchPlugins.elasticsearch_kopf];
  };

  services.kibana = {
    enable = true;
  };
}
