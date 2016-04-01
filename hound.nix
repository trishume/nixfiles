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
houndRepos = [
  { user = "NixOS"; repo = "nixpkgs"; }
  { user = "itseez"; repo = "opencv"; }
  { user = "openframeworks"; repo = "openFrameworks"; }
  { user = "syl20bnr"; repo = "spacemacs"; }
  { user = "ktossell"; repo = "libuvc"; }
  { user = "pupil-labs"; repo = "pupil"; }
];
houndConf = builtins.toFile "config.json" (builtins.toJSON {
  max-concurrent-indexers = 2;
  dbpath = "${houndDir}/data";
  repos = builtins.listToAttrs
    (map ({user, repo}: {name = "${repo}"; value = { url = "https://www.github.com/${user}/${repo}.git";};}) houndRepos);
});
hounddLauncher = with pkgs; stdenv.mkDerivation {
  name = "houndd-launcher";
  phases = [ "installPhase" ];
  buildInputs = [ makeWrapper ];
  installPhase = ''
    mkdir -p $out/bin
    ln -s ${hound.bin}/bin/houndd $out/bin/houndd
    wrapProgram $out/bin/houndd \
      --set SSL_CERT_FILE "/etc/ssl/certs/ca-certificates.crt" \
      --prefix PATH : "${git}/bin"
  '';
};
in
{
  environment.systemPackages = with pkgs; [
    hound.bin
   ];

  users.extraUsers = pkgs.lib.singleton {
    name = "hound";
    description = "Hound server user";
    uid = 200002;
    home = houndDir;
    isSystemUser = true;
    createHome = true;
  };
  systemd.services.houndd = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${hounddLauncher}/bin/houndd -conf=${houndConf}";
      User = "hound";
      Restart = "on-failure";
      WorkingDirectory = houndDir;
    };
  };

  services.nginx.httpConfig = ''
    server {
      server_name hound.thume.net;
      location / {
        proxy_set_header Host $http_host;
        proxy_redirect off;
        proxy_pass http://127.0.0.1:6080;
      }
    }
  '';

  networking.firewall.allowedTCPPorts = [9001 6080];
}
