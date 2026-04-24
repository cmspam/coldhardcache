# Hardware-specific configuration for ASUS ROG Zephyrus GA402X
{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [ ../../modules/hardware/nvidia.nix ];

  # SSD TRIM
  services.fstrim.enable = true;

  # WiFi power management tweaks for this chipset
  boot.extraModprobeConfig = ''
    options iwlwifi power_save=0
    options iwlmvm power_scheme=1

  '';
  # networking.networkmanager.wifi.powersave = false;

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.hardware.bolt.enable = true;

  # Laptop NVIDIA power extras — dGPU suspends when idle, dynamic boost on
  hardware.nvidia = {
    powerManagement.finegrained = true;
    dynamicBoost.enable = lib.mkForce true;
  };

  # SuperGFXD for AMD/NVIDIA graphics switching
  services.supergfxd.enable = true;

  # ASUS-specific services and utilities
  services.asusd.enable = true;

  # Custom keyboard mapping for ROG key
  services.udev.extraHwdb = lib.mkForce "evdev:name:*:dmi:bvn*:bvr*:bd*:svnASUS*:pn*:*\n KEYBOARD_KEY_ff31007c=f20\n\nevdev:input:b*v0B05p*\n KEYBOARD_KEY_ff310038=sysrq\n";

  # Enable SysRq key
  boot.kernel.sysctl = {
    "kernel.sysrq" = 1;
  };

  # GPU switching helper scripts
  environment.systemPackages =
    let
      # Force NVIDIA RTX 4090
      nvidia-run = pkgs.writeShellScriptBin "nvidia-run" ''
        export __NV_PRIME_RENDER_OFFLOAD=1
        export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
        export __GLX_VENDOR_LIBRARY_NAME=nvidia
        export __VK_LAYER_NV_optimus=NVIDIA_only
        export VK_ICD_FILENAMES=/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json
        exec "$@"
      '';

      # Force AMD Radeon 780M
      amd-run = pkgs.writeShellScriptBin "amd-run" ''
        export DRI_PRIME=1
        export VK_ICD_FILENAMES=/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json
        exec "$@"
      '';
    in
    with pkgs;
    [
      nvidia-run
      amd-run
      supergfxctl
      supergfxctl-plasmoid
      asusctl
    ];
}
