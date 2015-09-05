# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  networking.hostName = "nixbox"; # Define your hostname.

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/vda";

  networking.hostId = "7fde2033";

  swapDevices = [ { device = "/var/swapfile"; size = 2048; } ];

  environment.systemPackages = with pkgs; [
    wget
    vim
    ranger
    gitAndTools.gitFull
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  security.sudo.wheelNeedsPassword = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.tristan = {
    isNormalUser = true;
    uid = 1000;
    home = "/home/tristan";
    description = "Tristan Hume";
    extraGroups = ["wheel" "networkmanager"];
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDCTdKA76QGYiPsxKT+/j5Mxm8y7zOp2zGag57zZFpMeL5d3+KPx0cDqsa7NHqKJ2O1f6CKBgiCOIQdT5pS6/16v0Pu957wsP4Ljl7GLQ4mO+GOB932pgvWZFZ4jlW5TdzTl100yQ1h6rUfZjLA9tF+4zBTBN2t1qRZJnb5ncXZTmICgZc/SH2y8TNDUS2UGXj/wAOPTsgR33DIfnVxTlzRY9OnJDuDaWgoJfA01tJ1sDYKjzva3pOdsLmL1226vtvv/N/2JLqSL/9SH/LZIbYctUost8cBKzc5/FLTjKPB/FogNZGPSvUTGeqpBwR1L3WgdNBBygBIFeyyyOxDRZUd trishume@gmail.com"];
  };

}
