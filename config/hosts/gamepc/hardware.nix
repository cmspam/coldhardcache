# Hardware-specific configuration for gamepc
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

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Enable SysRq key
  boot.kernel.sysctl = {
    "kernel.sysrq" = 1;
  };

  # Delay resume to stop nvidia race condition
  systemd.services.nvidia-resume-delay = {
    description = "Brief delay after Nvidia resume";
    after = [ "nvidia-resume.service" ];
    wantedBy = [ "post-resume.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.coreutils}/bin/sleep 3";
    };
  };
  systemd.services.nvidia-suspend-delay = {
    description = "Brief delay before Nvidia suspend";
    before = [ "nvidia-suspend.service" ];
    wantedBy = [ "sleep.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.coreutils}/bin/sleep 3";
    };
  };

}
