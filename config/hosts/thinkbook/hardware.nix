# Hardware-specific configuration for Thinkbook
{
  config,
  lib,
  pkgs,
  ...
}:

{
  # SSD TRIM
  services.fstrim.enable = true;

  # WiFi power management tweaks for this chipset
  boot.extraModprobeConfig = ''
    options iwlwifi power_save=0
    options iwlmvm power_scheme=1
  '';
  networking.networkmanager.wifi.powersave = false;

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.hardware.bolt.enable = true;

  # Zram Swap
  zramSwap = {
    enable = true;
    algorithm = "zstd"; # Best compression ratio, same as your btrfs
    memoryPercent = 50; # Default; gives you up to 50% of RAM as compressed swap
  };

  # Enable hapticctl
  services.hapticctl = {
    enable = true;
    defaultIntensity = 100;
  };

  # Enable SysRq key
  boot.kernel.sysctl = {
    "kernel.sysrq" = 1;
  };
  # Keyboard Backlight service
  systemd.services.kbd-backlight-save = {
    description = "Save Keyboard Backlight State";
    before = [ "sleep.target" ];
    wantedBy = [ "sleep.target" ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.coreutils}/bin/cat /sys/class/leds/platform::kbd_backlight/brightness > /var/tmp/kbd_state'";
    };
  };

  systemd.services.kbd-backlight-restore = {
    description = "Restore Keyboard Backlight State";
    after = [
      "suspend.target"
      "hibernate.target"
      "hybrid-sleep.target"
    ];
    wantedBy = [
      "suspend.target"
      "hibernate.target"
      "hybrid-sleep.target"
    ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c 'sleep 2 && ${pkgs.coreutils}/bin/tee /sys/class/leds/platform::kbd_backlight/brightness < /var/tmp/kbd_state > /dev/null'";
    };
  };

}
