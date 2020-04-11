{ config, pkgs, ... }:
{
  imports = [
    # ./rate-with-science.nix
    # ./hound.nix
    # ./dayder.nix
    # ./hnblogs.nix
    # ./netdata.nix
    # ./kibana.nix
  ];
  environment.systemPackages = with pkgs; [
    tmux
    # weechat
    rr
   ];
}
