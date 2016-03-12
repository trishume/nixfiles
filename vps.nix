{ config, pkgs, ... }:
let
hound = with pkgs; with pkgs.goPackages; buildGoPackage rec {
  rev  = "0a364935ba9db53e6f3f5563b02fcce242e0930f";
  name = "hound-${stdenv.lib.strings.substring 0 7 rev}";
  goPackagePath = "github.com/etsy/hound";

  src = fetchFromGitHub {
    inherit rev;
    owner  = "etsy";
    repo   = "hound";
    sha256 = "0jhnjskpm15nfa1cvx0h214lx72zjvnkjwrbgwgqqyn9afrihc7q";
  };
  buildInputs = [ go-bindata.bin pkgs.nodejs pkgs.nodePackages.react-tools pkgs.python pkgs.rsync ];
  postInstall = ''
    pushd go
    python src/github.com/etsy/hound/tools/setup
    sed -i 's|bin/go-bindata||' Makefile
    sed -i 's|$<|#go-bindata|' Makefile
    make
  '';
};
houndDir = "/var/lib/hound";
houndConf = builtins.toFile "config.json" (builtins.toJSON {
  max-concurrent-indexers = 2;
  dbpath = "data";
  repos = {
      nixpkgs = {
          "url" = "https://www.github.com/NixOS/nixpkgs.git";
      };
  };
});
in
{
  imports = [
    ./rate-with-science.nix
    # ./kibana.nix
  ];
  environment.systemPackages = with pkgs; [
    tmux
    weechat
    hound.bin
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

  users.extraUsers = pkgs.lib.singleton {
    name = "hound";
    description = "Hound server user";
    uid = 200002;
    home = houndDir;
    isSystemUser = true;
  };
  systemd.services.houndd = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${hound.bin}/bin/houndd -conf=${houndConf}";
      User = "hound";
      Restart = "on-failure";
      WorkingDirectory = houndDir;
    };
  };

  networking.firewall.allowedTCPPorts = [9001 6080];
}
