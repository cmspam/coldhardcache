# Boot configuration specific to ASUS Zephyrus
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
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/efi";
    };

    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };

    # Latest kernel
    kernelPackages = pkgs.linuxPackages_latest;

    # Keyboard and GPU parameters for this hardware
    kernelParams = [
      "i8042.reset=1"
      "i8042.nomux=1"
      "asus_wmi.kbd_rgb_mode=0"
      "amdgpu.gpu_recovery=1"
      "amdgpu.dcdebugmask=0x10"
    ];

    # Keyboard modules
    initrd.availableKernelModules = [
      "atkbd"
      "i8042"
    ];
    initrd.kernelModules = [
      "atkbd"
      "i8042"
    ];

    # LUKS encryption with TPM2
    initrd.luks.devices."luks-b49c55b6-2daf-429a-8d07-ffbe8b2f6be4" = {
      device = "/dev/disk/by-uuid/b49c55b6-2daf-429a-8d07-ffbe8b2f6be4";
      preLVM = true;
      allowDiscards = true; # SSD optimization
      crypttabExtraOpts = [ "tpm2-device=auto" ];
    };

    # Enable systemd in initrd for TPM
    initrd.systemd.enable = true;

    # FUSE support
    supportedFilesystems = [ "fuse" ];
  };

  # Secure Boot tools
  environment.systemPackages = [ pkgs.sbctl ];
}
