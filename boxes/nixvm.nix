{ config, pkgs, ... }:

{
  imports =
    [
      ../base.nix
      ../dev-vm.nix
    ];

  networking.hostName = "nixvm"; # Define your hostname.
  # networking.hostId = "7fde2033";

  virtualisation.vmware.guest = {
    enable = true;
    headless = true;
  };
}
