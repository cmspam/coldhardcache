# gamepc Configuration
{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./hardware.nix
    ./boot.nix
    ./services.nix

    ../../modules/common
    ../../modules/desktop
    ../../modules/gaming
    ../../modules/gaming/jovian.nix
    ../../modules/gaming/sunshine.nix
    ../../modules/locale/japan.nix
    ../../modules/networking/sshd.nix
    ../../modules/networking/bbr.nix
    ../../modules/input/mongolian-keyboard.nix
    ../../modules/input/controllers.nix
    ../../modules/boot/bootwindows.nix
  ];

  networking.hostName = "gamepc";
  system.stateVersion = "25.11";
}
