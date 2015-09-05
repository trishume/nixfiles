{ config, pkgs, ... }:

{
  networking.networkmanager.enable = true;

  i18n = {
     consoleKeyMap = "dvorak";
     defaultLocale = "en_US.UTF-8";
  };

  environment.systemPackages = with pkgs; [
     coreutils
     gnome3.dconf
     emacs # see below for my own definition of Emacs
     ghostscript # to manipulate pdf files
     glxinfo
     glib # for gsettings
     xlibs.xev
     xorg.xkill
   ];

  services = {
    printing.enable = true;

    gnome3 = {
      tracker.enable = false; # I don't use tracker
      gnome-keyring.enable = true;
    };

    xserver = {
      enable = true;

      layout = "dvorak";

      # Gnome 3 works better with GDM
      displayManager.gdm.enable = true;

      # https://github.com/NixOS/nixpkgs/issues/4416
      displayManager.desktopManagerHandlesLidAndPower = false;

      # I want Gnome 3
      desktopManager.gnome3.enable = true;

      # This is the way to activate some Gnome 3 modules
      desktopManager.gnome3.sessionPath = with pkgs.gnome3_12; [ gpaste ];
      # xkbOptions = "ctrl:nocaps"; # overriden by gnome (must be set using gnome tweak tool)
      videoDrivers = pkgs.lib.mkOverride 40 [ "virtualbox" "vmware" "cirrus" "vesa" ];
    };
  };

  # Use Gnome 3.12
  environment.gnome3.packageSet = pkgs.gnome3_12;

  nixpkgs.config = {
    allowUnfree = true;
    firefox = {
      enableGoogleTalkPlugin = true;
      enableAdobeFlash = true;
    };

    pidgin = {
      openssl = true;
      gnutls = true;
    };

    packageOverrides = pkgs: {
        # Define my own Emacs
        emacs = pkgs.lib.overrideDerivation (pkgs.emacs.override {
            # Use gtk3 instead of the default gtk2
            gtk = pkgs.gtk3;
            # Make sure imagemgick is a dependency because I regularly
            # look at pictures from Emasc
            imagemagick = pkgs.imagemagickBig;
          }) (attrs: { });
    };

  };

  # Add fonts
  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      corefonts # Microsoft free fonts
      inconsolata # monospaced
      ubuntu_font_family
      dejavu_fonts
    ];
  };

  # Fix problem with Emacs tramp (https://github.com/NixOS/nixpkgs/issues/3368)
  # programs.bash = {
  #   promptInit = "PS1=\"# \"";
  #   enableCompletion = true;
  # };
}
