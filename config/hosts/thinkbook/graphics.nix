# Hardware-specific configuration for Thinkbook
{
  config,
  lib,
  pkgs,
  ...
}:
{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
      libva-utils
      vulkan-loader
      vulkan-validation-layers
      intel-compute-runtime
    ];
  };
}
