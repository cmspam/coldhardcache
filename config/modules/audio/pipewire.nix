# PipeWire audio server
{ config, pkgs, ... }:

{
  # Disable PulseAudio
  services.pulseaudio.enable = false;

  # Enable RealtimeKit for low-latency audio
  security.rtkit.enable = true;

  # PipeWire configuration
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
