# Boot configuration specific to Thinkbook
{
  config,
  pkgs,
  lib,
  ...
}:

{
  boot = {
    # Bootloader with Secure Boot support
    loader = {
      systemd-boot.enable = lib.mkForce false;
    };

    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };

    # Latest kernel
    # kernelPackages = pkgs.linuxPackages_latest;
    kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-x86_64-v3;
    kernelParams = [
      "fred=on"
    ];

    # Enable systemd in initrd for TPM
    initrd.systemd.enable = true;

    # FUSE support
    supportedFilesystems = [ "fuse" ];
  };

  # Secure Boot tools
  environment.systemPackages = [ pkgs.sbctl ];
}
