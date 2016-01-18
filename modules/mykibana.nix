{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.kibana;

  cfgFile = pkgs.writeText "kibana.json" (builtins.toJSON (
    (filterAttrsRecursive (n: v: v != null) ({
      server = {
        host = cfg.listenAddress;
        port = cfg.port;
        ssl = {
          cert = cfg.cert;
          key = cfg.key;
        };
      };

      kibana = {
        index = cfg.index;
        defaultAppId = cfg.defaultAppId;
      };

      elasticsearch = {
        url = cfg.elasticsearch.url;
        username = cfg.elasticsearch.username;
        password = cfg.elasticsearch.password;
        ssl = {
          cert = cfg.elasticsearch.cert;
          key = cfg.elasticsearch.key;
          ca = cfg.elasticsearch.ca;
        };
      };

      logging = {
        verbose = cfg.logLevel == "verbose";
        quiet = cfg.logLevel == "quiet";
        silent = cfg.logLevel == "silent";
        dest = "stdout";
      };
    } // cfg.extraConf)
  )));
in {
  config = mkIf (cfg.enable) {
    systemd.services.kibana.enable = false;
    systemd.services.mykibana = {
      description = "Kibana Service (fixed)";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-interfaces.target" "elasticsearch.service" ];
      environment = {
        "NODE_ENV" = "production";
        "CONFIG_PATH" = "${pkgs.kibana}/libexec/kibana/config/kibana.yml";
      };
      serviceConfig = {
        ExecStart = "${pkgs.nodejs}/bin/node ${pkgs.kibana}/libexec/kibana/src/bin/kibana.js --config ${cfgFile}";
        User = "kibana";
        WorkingDirectory = cfg.dataDir;
      };
    };
  };
}
