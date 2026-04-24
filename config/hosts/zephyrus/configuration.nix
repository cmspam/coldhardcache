# ASUS ROG Zephyrus GA402X Configuration
{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./hardware.nix
    ./boot.nix
    ./services.nix

    ../../modules/common
    ../../modules/desktop/plasma.nix
    ../../modules/gaming
    ../../modules/locale/japan.nix
    ../../modules/power/laptop.nix
    ../../modules/networking/bbr.nix
    ../../modules/input/mongolian-keyboard.nix
    ../../modules/input/touchpad.nix
    ../../modules/boot/bootwindows.nix
    ../../modules/virt/podman.nix
    ../../modules/virt/distrobox.nix
  ];

  networking.hostName = "zephyrus";
  system.stateVersion = "25.11";
}
