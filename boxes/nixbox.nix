{ config, pkgs, ... }:

{
  imports =
    [
      ../base.nix
    ];

  networking.hostName = "nixbox"; # Define your hostname.
  networking.hostId = "7fde2033";

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/vda";
}
