{ config, pkgs, ... }:

{
  hardware.xone.enable = true;
  environment.systemPackages = with pkgs; [
    evdevhook2
  ];

  # evdevhook2 Service
  systemd.services.evdevhook2 = {
    description = "evdevhook2 Input Hook Service";

    # Ensures the service starts automatically on boot
    wantedBy = [ "multi-user.target" ];

    # Ensure it starts after the graphical session or basic system is ready
    after = [ "network.target" ];

    serviceConfig = {
      # This points directly to the binary in the Nix store
      ExecStart = "${pkgs.evdevhook2}/bin/evdevhook2";

      # Basic reliability settings
      Restart = "always";
      RestartSec = "5s";

      # Running as root
      User = "root";

      # If the binary needs a specific working directory or environment variables:
      # WorkingDirectory = "/var/lib/evdevhook2";
    };
  };
}
