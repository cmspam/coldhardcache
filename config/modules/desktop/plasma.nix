# KDE Plasma Desktop Environment
{ config, pkgs, ... }:

{
  imports = [
    ../audio/pipewire.nix
    ../printing/cups.nix
  ];

  # X11 windowing system
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  # Display manager and desktop
  #  services.displayManager.sddm.enable = true;
  services.displayManager.plasma-login-manager.enable = true;
  services.desktopManager.plasma6.enable = true;

  # XDG portals for desktop integration
  xdg.portal.enable = true;

  # Basic desktop packages
  environment.systemPackages = with pkgs; [
    kdePackages.kate
    kdePackages.qtdeclarative
    kdePackages.kwin
    kdePackages.kdeconnect-kde
    tesseract
    haruna
    localsend
    (kdePackages.spectacle.override {
      tesseractLanguages = [
        "eng"
        "jpn"
      ];
    })
  ];
}
