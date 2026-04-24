{ pkgs, ... }:

{
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true; # Required for Wayland/KMS (Gamescope)
    openFirewall = true;
    package = pkgs.sunshine.override {
      cudaSupport = true;
      cudaPackages = pkgs.cudaPackages; # <-- I needed this bit
    };

  };
  services.udev.extraRules = ''
    KERNEL=="uinput", SUBSYSTEM=="misc", OPTIONS+="static_node=uinput", TAG+="uaccess", GROUP="input", MODE="0660"
    KERNEL=="uhid", SUBSYSTEM=="misc", OPTIONS+="static_node=uhid", TAG+="uaccess", GROUP="input", MODE="0660"
  '';
  # Required for Sunshine to "type" and "move the mouse"
  boot.kernelModules = [
    "uinput"
    "uhid"
  ];

  # For discovery (makes your PC show up automatically in Moonlight)
  services.avahi = {
    enable = true;
    publish = {
      enable = true;
      userServices = true;
    };
  };
}
