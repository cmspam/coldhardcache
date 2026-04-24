{ pkgs, ... }:

{
  # 1. The Service (Runs as root)
  systemd.services.reboot-to-windows = {
    description = "Reboot to Windows";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/bootctl set-oneshot auto-windows";
      ExecStopPost = "${pkgs.systemd}/bin/systemctl reboot";
    };
  };

  # 2. Polkit Rule for the 'wheel' group
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.systemd1.manage-units" &&
          action.lookup("unit") == "reboot-to-windows.service" &&
          subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';

  # 3. The Trigger Script for Steam
  environment.systemPackages = [
    (pkgs.writeScriptBin "reboot-to-windows" ''
      #!/usr/bin/env bash
      # No sudo required for users in the wheel group
      systemctl start reboot-to-windows.service
    '')
  ];
}
