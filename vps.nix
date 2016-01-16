{ config, pkgs, ... }:

{
  imports = [ ./rate-with-science.nix ];
  environment.systemPackages = with pkgs; [
    tmux
    weechat
   ];

  # See https://weechat.org/files/doc/devel/weechat_quickstart.en.html for
  # manual setup. Weechat uses a weird mutable config file system that
  # doesn't play well with NixOS immutability
  #
  # Also run the following to set up the relay:
  # /set relay.network.password yourpassword
  # /relay add weechat 9001
  systemd.services.ircSession = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Type = "forking";
      User = "tristan";
      ExecStart = ''${pkgs.tmux}/bin/tmux new-session -d -s irc -n irc ${pkgs.weechat}/bin/weechat'';
      ExecStop = ''${pkgs.tmux}/bin/tmux kill-session -t irc'';
    };
  };

  networking.firewall.allowedTCPPorts = [9001];
}
