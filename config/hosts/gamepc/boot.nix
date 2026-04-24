# Boot configuration specific to gamepc
{
  config,
  pkgs,
  lib,
  ...
}:

{
  boot = {
    # Bootloader with Secure Boot support
    plymouth.enable = true;

    loader = {
      systemd-boot.enable = lib.mkForce false;
      systemd-boot.consoleMode = "max";
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/efi";
    };

    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };

    # Latest kernel
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [ "quiet" ];
    # Enable systemd in initrd for TPM
    initrd.systemd.enable = true;
    # FUSE support
    supportedFilesystems = [ "fuse" ];
    consoleLogLevel = 0;
  };

}
