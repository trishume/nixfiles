{ config, lib, pkgs, ... }:
let
  cfg = config.services.fourStore;
  reposDir = "/var/nixoku";
  nixokuUser = "nixoku";
in
with lib;
{

  ###### interface

  options = {
    services.nixoku = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable nixoku.";
      };
    };
  };

  ###### implementation

  config = mkIf cfg.enable {
    users.extraUsers = singleton
      { name = nixokuUser;
        uid = 400;
        description = "Nixoku user";
        home = stateDir;
      };
  };

}
