# Machine-specific services for Zephyrus
{ config, pkgs, ... }:

{
  # BitLocker Windows Drive Access
  systemd.services.bitlocker-unlock = {
    description = "Unlock BitLocker Windows Drive";
    wantedBy = [ "multi-user.target" ];
    after = [ "local-fs.target" ];
    before = [ "mnt-windows.mount" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.cryptsetup}/bin/cryptsetup bitlkOpen --key-file /etc/bitlocker/recovery-key.txt /dev/disk/by-id/nvme-Lexar_SSD_NM790_4TB_NJF381R010478P2202_1-part3 bitlocker-drive";
      ExecStop = "${pkgs.cryptsetup}/bin/cryptsetup bitlkClose bitlocker-drive";
    };
  };

  # Mount the decrypted BitLocker volume
  fileSystems."/mnt/windows" = {
    device = "/dev/mapper/bitlocker-drive";
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
      "x-systemd.requires=bitlocker-unlock.service"
      "x-systemd.after=bitlocker-unlock.service"
      "dmask=0022"
      "fmask=0022"
    ];
  };

  # Ensure mount point exists
  systemd.tmpfiles.rules = [
    "d /mnt/windows 0755 root root -"
  ];

  # Secure the BitLocker key file
  system.activationScripts.bitlocker-key-perms = ''
    if [ -f /etc/bitlocker/recovery-key.txt ]; then
      chmod 600 /etc/bitlocker/recovery-key.txt
      chown root:root /etc/bitlocker/recovery-key.txt
    fi
  '';
}
