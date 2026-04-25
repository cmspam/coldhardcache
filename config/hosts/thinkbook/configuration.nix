# Thinkbook Configuration
{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./hardware.nix
    ./boot.nix
    ./fixes.nix
    ./graphics.nix

    ../../modules/common
    ../../modules/desktop
    ../../modules/gaming
    ../../modules/locale/japan.nix
    ../../modules/virt/waydroid.nix
    ../../modules/virt/podman.nix
    ../../modules/virt/distrobox.nix
    ../../modules/input/mongolian-keyboard.nix
    ../../modules/input/touchpad.nix
    ../../modules/input/copilot-key.nix
    ../../modules/power/battery-watch.nix
  ];

  networking.hostName = "thinkbook";
  nix.settings.auto-optimise-store = true;
  system.stateVersion = "25.11";
}
