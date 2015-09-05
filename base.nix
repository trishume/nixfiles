{ config, pkgs, ... }:

{
  time.timeZone = "US/Eastern";

  security.sudo.wheelNeedsPassword = false;
  swapDevices = [ { device = "/var/swapfile"; size = 2048; } ];

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
     ack
     aspell
     aspellDicts.en
     bashCompletion
     coreutils
     gitAndTools.gitFull
     gnumake
     htop
     ranger
     utillinux # for dmesg, kill,...
     vim
     wget
     which
     zip
   ];

  services = {
    openssh.enable = true;

    # Locate will update its database everyday at lunch time
    # locate.enable = true;
    # locate.period = "00 12 * * *";
  };

  nixpkgs.config = {
    allowUnfree = true;
  };

  # Make sure the only way to add users/groups is to change this file
  # users.mutableUsers = false;

  # Add myself as a super user
  users.extraUsers.tristan = {
    createHome = true;
    isNormalUser = true;
    useDefaultShell = true;
    uid = 1000;
    home = "/home/tristan";
    description = "Tristan Hume";
    extraGroups = ["wheel" "networkmanager"];
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDCTdKA76QGYiPsxKT+/j5Mxm8y7zOp2zGag57zZFpMeL5d3+KPx0cDqsa7NHqKJ2O1f6CKBgiCOIQdT5pS6/16v0Pu957wsP4Ljl7GLQ4mO+GOB932pgvWZFZ4jlW5TdzTl100yQ1h6rUfZjLA9tF+4zBTBN2t1qRZJnb5ncXZTmICgZc/SH2y8TNDUS2UGXj/wAOPTsgR33DIfnVxTlzRY9OnJDuDaWgoJfA01tJ1sDYKjzva3pOdsLmL1226vtvv/N/2JLqSL/9SH/LZIbYctUost8cBKzc5/FLTjKPB/FogNZGPSvUTGeqpBwR1L3WgdNBBygBIFeyyyOxDRZUd trishume@gmail.com"];
  };
}
