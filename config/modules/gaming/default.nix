# Gaming configuration - Steam, performance tools, game launchers
{ config, pkgs, ... }:

{
  # Steam with Gamescope session
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };

  # GameMode for performance optimization
  programs.gamemode.enable = true;

  # Gaming packages
  environment.systemPackages = with pkgs; [
    # Performance overlay
    mangohud

    # Proton management
    protonup-qt

    # Alternative game launchers
    lutris
    bottles
    heroic

    # Steam Deck utilities
    steam-rom-manager
  ];
}
