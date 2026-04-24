# Machine-specific services for gamepc
{ config, pkgs, ... }:

{
  # Mount the decrypted volume
  fileSystems."/mnt/windows" = {
    device = "/dev/nvme0n1p3";
    fsType = "ntfs3";
    options = [
      "rw"
      "force"
      "uid=1000"
      "gid=100"
      "nocase"
      "windows_names"
      "x-gvfs-show"
      "nofail"
      "dmask=0022"
      "fmask=0022"
    ];
  };

  # Mount the decrypted volume
  fileSystems."/mnt/SSD" = {
    device = "/dev/disk/by-label/SSD";
    fsType = "ntfs3";
    options = [
      "rw"
      "force"
      "uid=1000"
      "gid=100"
      "nocase"
      "windows_names"
      "x-gvfs-show"
      "nofail"
      "dmask=0022"
      "fmask=0022"
    ];
  };

  # Mount the decrypted volume
  fileSystems."/mnt/HD1" = {
    device = "/dev/disk/by-label/HD1";
    fsType = "ntfs3";
    options = [
      "rw"
      "force"
      "uid=1000"
      "gid=100"
      "nocase"
      "windows_names"
      "x-gvfs-show"
      "nofail"
      "dmask=0022"
      "fmask=0022"
    ];
  };

  # Mount the decrypted volume
  fileSystems."/mnt/HD2" = {
    device = "/dev/disk/by-label/HD2";
    fsType = "ntfs3";
    options = [
      "rw"
      "force"
      "uid=1000"
      "gid=100"
      "nocase"
      "windows_names"
      "x-gvfs-show"
      "nofail"
      "dmask=0022"
      "fmask=0022"
    ];
  };

  # Ensure the mount point exists
  systemd.tmpfiles.rules = [
    "d /mnt/windows 0755 root root -"
  ];

  # Xbox One Controller Enablement
  hardware.xone.enable = true;

  # 8bit do suspend support
  powerManagement.powerDownCommands = ''
    # Check if the device exists to prevent script errors
    if [ -e /sys/bus/usb/devices/1-1/authorized ]; then
      echo 0 > /sys/bus/usb/devices/1-1/authorized
      # This force-pauses the suspend process for 10 seconds
      ${pkgs.coreutils}/bin/sleep 10
    fi
  '';
  services.udev.extraRules = ''
    # Enable wakeup for the Root Hub of Bus 1
    SUBSYSTEM=="usb", KERNEL=="usb1", ATTR{power/wakeup}="enabled"

    # Enable wakeup for the specific Port 1-1
    SUBSYSTEM=="usb", KERNEL=="1-1", ATTR{power/wakeup}="enabled"
  '';

}
