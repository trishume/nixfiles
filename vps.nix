{ config, pkgs, ... }:

{
  services.znc = {
    enable = true;
    mutable = true;
  };
}
