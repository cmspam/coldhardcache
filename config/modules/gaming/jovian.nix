# Jovian - Steam Deck UI experience
{ lib, me, ... }:
{
  jovian = {
    steam = {
      enable = true;
      autoStart = true;
      user = me.username;
      desktopSession = "plasma";
    };
    devices.steamdeck.enable = false; # We're on a regular PC
  };

  # Let Jovian handle the login flow instead of Plasma's
  services.displayManager.plasma-login-manager.enable = lib.mkForce false;
  services.displayManager.sddm.enable = lib.mkForce false;
}
